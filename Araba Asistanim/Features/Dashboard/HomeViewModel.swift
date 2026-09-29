import Combine
import Foundation

/// Presentation state for the Home dashboard. All data is sourced from
/// PreviewData in this phase — there is no backend or persistence yet.
@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var vehicle: Vehicle
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
        let vehicle = vehicle ?? PreviewData.featuredVehicle
        let nextMaintenanceItem = nextMaintenanceItem ?? PreviewData.nextMaintenanceItem

        self.vehicle = vehicle
        self.nextMaintenanceItem = nextMaintenanceItem
        self.nextServiceRemainingKm = (nextMaintenanceItem?.mileageKm ?? 0) - vehicle.mileageKm
        self.recentActivity = recentActivity ?? PreviewData.recentActivity
        self.aiInsightMessage = aiInsightMessage ?? PreviewData.aiInsightMessage
        self.aiInsightDetail = aiInsightDetail ?? PreviewData.aiInsightDetail

        self.fuelConsumptionText = PreviewData.fuelConsumptionValue.formattedFuelConsumption()
        self.fuelConsumptionChangePercent = PreviewData.fuelConsumptionChangePercent
        self.fuelHistory = PreviewData.monthlyFuelConsumption

        self.monthlyExpensesText = PreviewData.monthlyExpensesValue.formattedCurrencyTL()
        self.monthlyExpensesChangePercent = PreviewData.monthlyExpensesChangePercent
        self.expenseBreakdown = PreviewData.expenseBreakdown
    }

    func selectQuickAction(_ action: QuickActionType) {
        activeQuickAction = action
    }
}
