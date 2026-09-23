import Foundation

/// A quick-action shortcut on the Home dashboard. Selecting one shows a
/// placeholder sheet in this phase — no record is actually created yet.
enum QuickActionType: String, CaseIterable, Identifiable {
    case addFuel
    case addExpense
    case addMaintenance

    var id: String { rawValue }

    var title: String {
        switch self {
        case .addFuel: return "Add Fuel"
        case .addExpense: return "Add Expense"
        case .addMaintenance: return "Add Maintenance"
        }
    }

    var systemImage: String {
        switch self {
        case .addFuel: return "fuelpump.fill"
        case .addExpense: return "creditcard.fill"
        case .addMaintenance: return "wrench.and.screwdriver.fill"
        }
    }

    var placeholderMessage: String {
        "\(title) isn't implemented yet. Record creation will be available once backend integration is added."
    }
}
