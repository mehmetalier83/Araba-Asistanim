import Foundation

/// A single expense entry, used to drive the Home screen's recent activity feed.
/// All instances in this phase are mock/preview data.
struct ExpenseRecord: Identifiable, Hashable {
    let id: UUID
    let title: String
    let category: ExpenseCategory
    let amount: Double
    let date: Date

    init(
        id: UUID = UUID(),
        title: String,
        category: ExpenseCategory,
        amount: Double,
        date: Date
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.amount = amount
        self.date = date
    }
}

enum ExpenseCategory: String, CaseIterable, Hashable {
    case maintenance
    case fuel
    case other

    var systemImage: String {
        switch self {
        case .maintenance: return "wrench.and.screwdriver.fill"
        case .fuel: return "fuelpump.fill"
        case .other: return "creditcard.fill"
        }
    }
}
