import Combine
import Foundation

/// Form state for logging a completed maintenance service. Mirrors
/// `AddExpenseViewModel`/`AddFuelViewModel`'s shape and validation style so
/// all three "Add" flows feel like one system. Always builds a `.completed`
/// record — scheduling a *future* reminder is a different feature, not this
/// one (this logs work that already happened, same as the other two forms).
@MainActor
final class AddMaintenanceViewModel: ObservableObject {
    let vehicle: Vehicle

    @Published var category: MaintenanceCategory?
    @Published var costText: String = ""
    @Published var date: Date = .now
    @Published var mileageText: String
    @Published var serviceName: String = ""
    @Published var receiptImageData: Data?
    @Published var didAutoFillFromReceipt = false

    @Published private(set) var categoryError: String?
    @Published private(set) var costError: String?
    @Published private(set) var mileageError: String?

    private let editingID: UUID?
    private let createdAt: Date

    init(vehicle: Vehicle, existing: MaintenanceRecord? = nil) {
        self.vehicle = vehicle

        if let existing {
            self.category = existing.category
            self.costText = existing.cost.map(Self.decimalText) ?? ""
            self.date = existing.date
            self.mileageText = String(existing.mileageKm)
            self.serviceName = existing.serviceName ?? ""
            self.receiptImageData = existing.receiptImageData
            self.editingID = existing.id
            self.createdAt = existing.createdAt
        } else {
            self.mileageText = String(vehicle.mileageKm)
            self.editingID = nil
            self.createdAt = .now
        }
    }

    var costValue: Double { Double(costText) ?? 0 }

    func clearCategoryError() { categoryError = nil }
    func clearCostError() { costError = nil }
    func clearMileageError() { mileageError = nil }

    /// Pre-fills whatever the receipt scan found — only into fields the user
    /// hasn't already typed something into, so a scan never clobbers a
    /// manual edit. Everything it sets remains an ordinary editable field.
    func applyScanResult(_ result: ReceiptScanner.ScanResult) {
        var didFill = false

        if costText.isEmpty, let amount = result.amount {
            costText = Self.decimalText(for: amount)
            didFill = true
        }
        if category == nil, let category = result.maintenanceCategory {
            self.category = category
            didFill = true
        }
        if serviceName.isEmpty, let merchant = result.merchantName {
            serviceName = merchant
            didFill = true
        }

        if didFill {
            didAutoFillFromReceipt = true
        }
    }

    func buildRecord() -> MaintenanceRecord? {
        var isValid = true

        if category == nil {
            categoryError = "Bir kategori seç."
            isValid = false
        }

        if costValue <= 0 {
            costError = "Geçerli bir tutar gir."
            isValid = false
        }

        var mileage = 0
        let trimmedMileage = mileageText.trimmingCharacters(in: .whitespaces)
        if let value = Int(trimmedMileage), value >= 0 {
            mileage = value
        } else {
            mileageError = "Geçerli bir kilometre gir."
            isValid = false
        }

        guard isValid, let category else { return nil }

        let trimmedService = serviceName.trimmingCharacters(in: .whitespacesAndNewlines)

        return MaintenanceRecord(
            id: editingID ?? UUID(),
            vehicleID: vehicle.id,
            title: category.displayName,
            category: category,
            status: .completed,
            date: date,
            mileageKm: mileage,
            cost: costValue,
            serviceName: trimmedService.isEmpty ? nil : trimmedService,
            receiptImageData: receiptImageData,
            createdAt: createdAt,
            updatedAt: .now
        )
    }

    private static func decimalText(for value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", value)
            : String(format: "%.2f", value)
    }
}
