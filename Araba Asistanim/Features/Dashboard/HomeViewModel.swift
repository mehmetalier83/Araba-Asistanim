import Combine
import Foundation

/// Presentation state for the Home dashboard. All data is sourced from
/// PreviewData in this phase — there is no backend or persistence yet, and
/// only the seeded demo account gets that sample data; every other account
/// starts with `vehicle == nil` (a genuinely empty garage) until the person
/// adds their first vehicle from Home's own empty state.
@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var vehicle: Vehicle?
    @Published private(set) var nextMaintenanceItem: MaintenanceRecord?
    @Published private(set) var nextServiceRemainingKm: Int
    @Published private(set) var recentActivity: [ExpenseRecord]
    @Published private(set) var aiInsightMessage: String
    @Published private(set) var aiInsightDetail: String

    let fuelConsumptionText: String
    let fuelConsumptionChangePercent: Double
    let fuelHistory: [MonthlyValue]

    let monthlyExpensesText: String
    let monthlyExpensesChangePercent: Double
    let expenseBreakdown: [(category: ExpenseCategory, total: Double)]

    @Published var activeQuickAction: QuickActionType?
    @Published var isShowingInsightDetail = false
    @Published var isShowingAddVehicle = false

    /// Parameters default to `nil` and fall back to PreviewData inside the body
    /// (rather than in the parameter list) because default-argument expressions
    /// are evaluated in a nonisolated context in Swift's concurrency model,
    /// even though this initializer itself is MainActor-isolated.
    init(
        vehicle: Vehicle? = nil,
        nextMaintenanceItem: MaintenanceRecord? = nil,
        recentActivity: [ExpenseRecord]? = nil,
        aiInsightMessage: String? = nil,
        aiInsightDetail: String? = nil
    ) {
        let useSeedData = AppSession.isDemoAccount
        let vehicle = vehicle ?? (useSeedData ? PreviewData.featuredVehicle : nil)
        let nextMaintenanceItem = nextMaintenanceItem ?? (useSeedData ? PreviewData.nextMaintenanceItem : nil)

        self.vehicle = vehicle
        self.nextMaintenanceItem = nextMaintenanceItem
        self.nextServiceRemainingKm = (nextMaintenanceItem?.mileageKm ?? 0) - (vehicle?.mileageKm ?? 0)
        self.recentActivity = recentActivity ?? (useSeedData ? PreviewData.recentActivity : [])
        self.aiInsightMessage = aiInsightMessage ?? (useSeedData
            ? PreviewData.aiInsightMessage
            : "Araç ve kayıt ekledikçe burada kişisel analizler görünecek.")
        self.aiInsightDetail = aiInsightDetail ?? (useSeedData
            ? PreviewData.aiInsightDetail
            : "Yakıt, bakım ve gider kayıtların arttıkça AI asistanın tüketim ve maliyet eğilimlerini burada özetleyecek.")

        self.fuelConsumptionText = useSeedData ? PreviewData.fuelConsumptionValue.formattedFuelConsumption() : "—"
        self.fuelConsumptionChangePercent = useSeedData ? PreviewData.fuelConsumptionChangePercent : 0
        self.fuelHistory = useSeedData ? PreviewData.monthlyFuelConsumption : []

        self.monthlyExpensesText = useSeedData ? PreviewData.monthlyExpensesValue.formattedCurrencyTL() : "0 TL"
        self.monthlyExpensesChangePercent = useSeedData ? PreviewData.monthlyExpensesChangePercent : 0
        self.expenseBreakdown = useSeedData ? PreviewData.expenseBreakdown : []
    }

    func selectQuickAction(_ action: QuickActionType) {
        activeQuickAction = action
    }

    /// Called when the first vehicle is added from Home's own empty state —
    /// promotes it straight to the featured vehicle so the dashboard renders
    /// immediately instead of waiting for a relaunch.
    func setFeaturedVehicle(_ vehicle: Vehicle) {
        self.vehicle = vehicle
    }

    /// Reflects a newly-added expense in the "Son Hareketler" card immediately,
    /// without waiting for a full data reload — there is no backend to refetch
    /// from yet, so the dashboard updates its own in-memory copy directly.
    func recordExpense(_ expense: ExpenseRecord) {
        recentActivity.insert(expense, at: 0)
        if recentActivity.count > 3 {
            recentActivity = Array(recentActivity.prefix(3))
        }
    }

    /// A fuel fill-up is also a `.fuel`-category expense, so it's surfaced in
    /// "Son Hareketler" the same way `recordExpense` does — the two "Add"
    /// flows feed one unified activity feed instead of two disconnected ones.
    func recordFuel(_ fuelRecord: FuelRecord) {
        let expense = ExpenseRecord(
            vehicleID: fuelRecord.vehicleID,
            category: .fuel,
            amount: fuelRecord.cost,
            date: fuelRecord.date,
            mileageKm: fuelRecord.mileageKm,
            serviceName: fuelRecord.station,
            receiptImageData: fuelRecord.receiptImageData,
            createdAt: fuelRecord.createdAt
        )
        recordExpense(expense)
    }

    /// A completed maintenance service is also a `.maintenance`-category
    /// expense, surfaced in "Son Hareketler" the same way as fuel and
    /// regular expenses — one unified activity feed, not three.
    func recordMaintenance(_ record: MaintenanceRecord) {
        let expense = ExpenseRecord(
            vehicleID: record.vehicleID,
            category: .maintenance,
            amount: record.cost ?? 0,
            date: record.date,
            mileageKm: record.mileageKm,
            serviceName: record.serviceName,
            note: record.title,
            receiptImageData: record.receiptImageData,
            createdAt: record.createdAt
        )
        recordExpense(expense)
    }
}
