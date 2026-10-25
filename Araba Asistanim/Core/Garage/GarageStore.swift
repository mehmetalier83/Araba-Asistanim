import Combine
import Foundation

/// The single source of truth for one signed-in user's vehicles and records,
/// shared by every tab via the environment. Changes are applied in memory
/// first (so the UI updates immediately) and then written to the repository.
@MainActor
final class GarageStore: ObservableObject {
    @Published private(set) var vehicles: [Vehicle] = []
    @Published private(set) var fuelRecords: [FuelRecord] = []
    @Published private(set) var maintenanceRecords: [MaintenanceRecord] = []
    @Published private(set) var expenses: [ExpenseRecord] = []
    @Published private(set) var isLoaded = false
    /// Set when a load or save fails; shown once by SessionRootView, then cleared.
    @Published var syncErrorMessage: String?

    @Published var selectedVehicleID: UUID? {
        didSet { userDefaults.set(selectedVehicleID?.uuidString, forKey: selectedVehicleKey) }
    }

    private let repository: GarageRepository
    private let seedsDemoData: Bool
    private let userDefaults: UserDefaults
    private let selectedVehicleKey: String

    init(
        userID: String,
        repository: GarageRepository,
        seedsDemoData: Bool = false,
        userDefaults: UserDefaults = .standard
    ) {
        self.repository = repository
        self.seedsDemoData = seedsDemoData
        self.userDefaults = userDefaults
        self.selectedVehicleKey = "garage.selectedVehicle.\(userID)"
        self.selectedVehicleID = userDefaults.string(forKey: selectedVehicleKey).flatMap(UUID.init(uuidString:))
    }

    // MARK: - Loading

    func load() async {
        do {
            vehicles = try await repository.fetchAll(Vehicle.self).sorted { $0.displayName < $1.displayName }
            fuelRecords = try await repository.fetchAll(FuelRecord.self)
            maintenanceRecords = try await repository.fetchAll(MaintenanceRecord.self)
            expenses = try await repository.fetchAll(ExpenseRecord.self)

            if vehicles.isEmpty && seedsDemoData {
                await seedDemoData()
            }
        } catch {
            syncErrorMessage = "Kayıtların yüklenemedi. Lütfen uygulamayı yeniden başlat."
        }

        if selectedVehicle == nil {
            selectedVehicleID = vehicles.first?.id
        }
        isLoaded = true
    }

    /// The demo account gets the sample BMW/Corolla garage on first launch.
    /// Fuel and completed maintenance already appear in the ledger on their
    /// own, so only the remaining expense categories are seeded as expenses.
    ///
    /// The sample dates are fixed, so they're shifted forward to end a couple
    /// of days ago — otherwise "this month" would be empty for the demo.
    private func seedDemoData() async {
        let fuel = PreviewData.fuelRecords
        let maintenance = PreviewData.maintenanceRecords.filter { $0.status == .completed }
        let others = PreviewData.allExpenses.filter { $0.category != .fuel && $0.category != .maintenance }

        let latest = (fuel.map(\.date) + maintenance.map(\.date) + others.map(\.date)).max() ?? .now
        let shift = max(0, Date.now.addingTimeInterval(-2 * 86_400).timeIntervalSince(latest))

        PreviewData.vehicles.forEach(addVehicle)
        fuel.forEach { record in
            var record = record
            record.date += shift
            addFuel(record)
        }
        maintenance.forEach { record in
            var record = record
            record.date += shift
            addMaintenance(record)
        }
        others.forEach { record in
            var record = record
            record.date += shift
            addExpense(record)
        }
    }

    // MARK: - Vehicles

    var selectedVehicle: Vehicle? {
        vehicles.first { $0.id == selectedVehicleID } ?? vehicles.first
    }

    func vehicle(withID id: UUID) -> Vehicle? {
        vehicles.first { $0.id == id }
    }

    func addVehicle(_ vehicle: Vehicle) {
        vehicles.append(vehicle)
        if selectedVehicleID == nil || selectedVehicle?.id != selectedVehicleID {
            selectedVehicleID = vehicle.id
        }
        persist(vehicle)
    }

    func updateVehicle(_ vehicle: Vehicle) {
        guard let index = vehicles.firstIndex(where: { $0.id == vehicle.id }) else { return }
        vehicles[index] = vehicle
        persist(vehicle)
    }

    /// Removes the vehicle together with every record that belongs to it.
    func deleteVehicle(_ vehicle: Vehicle) {
        vehicles.removeAll { $0.id == vehicle.id }
        fuelRecords.filter { $0.vehicleID == vehicle.id }.forEach(deleteFuel)
        maintenanceRecords.filter { $0.vehicleID == vehicle.id }.forEach(deleteMaintenance)
        expenses.filter { $0.vehicleID == vehicle.id }.forEach(deleteExpense)
        remove(Vehicle.self, id: vehicle.id)

        if selectedVehicleID == vehicle.id {
            selectedVehicleID = vehicles.first?.id
        }
    }

    /// A record with a newer odometer reading moves the vehicle's mileage forward.
    private func bumpMileage(vehicleID: UUID, to mileage: Int?) {
        guard let mileage, var vehicle = vehicle(withID: vehicleID), mileage > vehicle.mileageKm else { return }
        vehicle.mileageKm = mileage
        updateVehicle(vehicle)
    }

    // MARK: - Fuel

    func fuelRecords(for vehicleID: UUID) -> [FuelRecord] {
        fuelRecords.filter { $0.vehicleID == vehicleID }.sorted { $0.date > $1.date }
    }

    func addFuel(_ record: FuelRecord) {
        upsert(record, in: &fuelRecords)
        bumpMileage(vehicleID: record.vehicleID, to: record.mileageKm)
    }

    func updateFuel(_ record: FuelRecord) {
        addFuel(record)
    }

    func deleteFuel(_ record: FuelRecord) {
        fuelRecords.removeAll { $0.id == record.id }
        remove(FuelRecord.self, id: record.id)
    }

    // MARK: - Maintenance

    func completedMaintenance(for vehicleID: UUID) -> [MaintenanceRecord] {
        maintenanceRecords
            .filter { $0.vehicleID == vehicleID && $0.status == .completed }
            .sorted { $0.date > $1.date }
    }

    /// Upcoming/overdue reminders derived from the completed history.
    func reminders(for vehicleID: UUID) -> [MaintenanceRecord] {
        guard let vehicle = vehicle(withID: vehicleID) else { return [] }
        return MaintenanceSchedule.reminders(for: vehicle, history: maintenanceRecords)
    }

    /// Overdue and due-soon reminders across every vehicle — the Home bell.
    var attentionReminders: [MaintenanceRecord] {
        vehicles.flatMap { reminders(for: $0.id) }.filter { $0.status == .overdue || $0.status == .dueSoon }
    }

    func addMaintenance(_ record: MaintenanceRecord) {
        upsert(record, in: &maintenanceRecords)
        bumpMileage(vehicleID: record.vehicleID, to: record.mileageKm)
    }

    func updateMaintenance(_ record: MaintenanceRecord) {
        addMaintenance(record)
    }

    func deleteMaintenance(_ record: MaintenanceRecord) {
        maintenanceRecords.removeAll { $0.id == record.id }
        remove(MaintenanceRecord.self, id: record.id)
    }

    // MARK: - Expenses

    func addExpense(_ expense: ExpenseRecord) {
        upsert(expense, in: &expenses)
        bumpMileage(vehicleID: expense.vehicleID, to: expense.mileageKm)
    }

    func deleteExpense(_ expense: ExpenseRecord) {
        expenses.removeAll { $0.id == expense.id }
        remove(ExpenseRecord.self, id: expense.id)
    }

    // MARK: - Unified ledger

    /// Every cost for a vehicle: plain expenses plus fuel fill-ups and
    /// completed maintenance, each shown as an expense with its source's id.
    func spending(for vehicleID: UUID) -> [ExpenseRecord] {
        let fuel = fuelRecords.filter { $0.vehicleID == vehicleID }.map(\.asExpense)
        let maintenance = maintenanceRecords
            .filter { $0.vehicleID == vehicleID && $0.status == .completed }
            .map(\.asExpense)
        return (expenses.filter { $0.vehicleID == vehicleID } + fuel + maintenance)
            .sorted { $0.date > $1.date }
    }

    func fuelRecord(withID id: UUID) -> FuelRecord? { fuelRecords.first { $0.id == id } }
    func maintenanceRecord(withID id: UUID) -> MaintenanceRecord? { maintenanceRecords.first { $0.id == id } }

    /// Saves an edit made from the ledger back to whichever record it came from.
    func updateSpending(_ expense: ExpenseRecord) {
        if var fuel = fuelRecord(withID: expense.id), expense.category == .fuel {
            fuel.cost = expense.amount
            fuel.date = expense.date
            fuel.mileageKm = expense.mileageKm ?? fuel.mileageKm
            fuel.station = expense.serviceName
            fuel.receiptImageData = expense.receiptImageData
            updateFuel(fuel)
        } else if var record = maintenanceRecord(withID: expense.id), expense.category == .maintenance {
            record.cost = expense.amount
            record.date = expense.date
            record.mileageKm = expense.mileageKm ?? record.mileageKm
            record.serviceName = expense.serviceName
            record.receiptImageData = expense.receiptImageData
            record.updatedAt = .now
            updateMaintenance(record)
        } else {
            // A category change moves a fuel/maintenance entry into a plain expense.
            if let fuel = fuelRecord(withID: expense.id) { deleteFuel(fuel) }
            if let record = maintenanceRecord(withID: expense.id) { deleteMaintenance(record) }
            addExpense(expense)
        }
    }

    func deleteSpending(_ expense: ExpenseRecord) {
        if let fuel = fuelRecord(withID: expense.id) {
            deleteFuel(fuel)
        } else if let record = maintenanceRecord(withID: expense.id) {
            deleteMaintenance(record)
        } else {
            deleteExpense(expense)
        }
    }

    /// Wipes every vehicle and record — used right before the account is deleted.
    func deleteAllData() async throws {
        try await repository.deleteAll()
        vehicles = []
        fuelRecords = []
        maintenanceRecords = []
        expenses = []
        selectedVehicleID = nil
    }

    // MARK: - Persistence

    private func upsert<T: GarageEntity>(_ item: T, in array: inout [T]) {
        if let index = array.firstIndex(where: { $0.id == item.id }) {
            array[index] = item
        } else {
            array.append(item)
        }
        persist(item)
    }

    private func persist<T: GarageEntity>(_ item: T) {
        Task {
            do {
                try await repository.upsert(item)
            } catch {
                syncErrorMessage = "Değişikliğin kaydedilemedi. Lütfen tekrar dene."
            }
        }
    }

    private func remove<T: GarageEntity>(_ type: T.Type, id: UUID) {
        Task {
            do {
                try await repository.delete(type, id: id)
            } catch {
                syncErrorMessage = "Silme işlemi kaydedilemedi. Lütfen tekrar dene."
            }
        }
    }
}

extension GarageStore {
    /// A demo-seeded, in-memory store for SwiftUI previews.
    static var preview: GarageStore {
        let store = GarageStore(userID: "preview", repository: InMemoryGarageRepository(), seedsDemoData: true)
        Task { await store.load() }
        return store
    }
}

private extension FuelRecord {
    var asExpense: ExpenseRecord {
        ExpenseRecord(
            id: id,
            vehicleID: vehicleID,
            category: .fuel,
            amount: cost,
            date: date,
            mileageKm: mileageKm,
            serviceName: station,
            note: String(format: "%.1f L%@", liters, isFullTank ? " · Depo full" : ""),
            receiptImageData: receiptImageData,
            createdAt: createdAt
        )
    }
}

private extension MaintenanceRecord {
    var asExpense: ExpenseRecord {
        ExpenseRecord(
            id: id,
            vehicleID: vehicleID,
            category: .maintenance,
            amount: cost ?? 0,
            date: date,
            mileageKm: mileageKm,
            serviceName: serviceName,
            note: title,
            receiptImageData: receiptImageData,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
