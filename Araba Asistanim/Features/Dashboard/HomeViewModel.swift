import Combine
import Foundation

/// Presentation state for the Home dashboard. All data is sourced from
/// PreviewData in this phase — there is no backend or persistence yet.
@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var vehicle: Vehicle
    @Published private(set) var healthRows: [VehicleHealthCard.Row]
    @Published private(set) var nextMaintenanceItem: MaintenanceRecord?
    @Published private(set) var recentActivity: [ExpenseRecord]
    @Published private(set) var aiInsightMessage: String
    @Published private(set) var aiInsightDetail: String

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
        self.recentActivity = recentActivity ?? PreviewData.recentActivity
        self.aiInsightMessage = aiInsightMessage ?? PreviewData.aiInsightMessage
        self.aiInsightDetail = aiInsightDetail ?? PreviewData.aiInsightDetail

        let remainingKm = (nextMaintenanceItem?.mileageKm ?? 0) - vehicle.mileageKm
        let nextServiceTag: (text: String, tone: TagView.Tone)?
        switch nextMaintenanceItem?.status {
        case .overdue: nextServiceTag = ("Overdue", .danger)
        case .dueSoon: nextServiceTag = ("Due Soon", .warning)
        default: nextServiceTag = nil
        }

        self.healthRows = [
            .init(
                systemImage: "fuelpump.fill",
                title: "Fuel Consumption",
                value: PreviewData.fuelConsumptionValue.formattedFuelConsumption()
            ),
            .init(
                systemImage: "banknote.fill",
                title: "Monthly Expenses",
                value: PreviewData.monthlyExpensesValue.formattedCurrencyTL()
            ),
            .init(
                systemImage: "wrench.and.screwdriver.fill",
                title: "Next Service",
                value: remainingKm > 0 ? "\(remainingKm.formattedMileage())" : abs(remainingKm).formattedMileage(),
                tag: nextServiceTag
            )
        ]
    }

    func selectQuickAction(_ action: QuickActionType) {
        activeQuickAction = action
    }
}
