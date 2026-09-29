import SwiftUI

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
    case fuel
    case maintenance
    case insurance
    case other

    var systemImage: String {
        switch self {
        case .maintenance: return "wrench.and.screwdriver.fill"
        case .fuel: return "fuelpump.fill"
        case .insurance: return "shield.fill"
        case .other: return "creditcard.fill"
        }
    }

    var displayName: String {
        switch self {
        case .maintenance: return "Bakım"
        case .fuel: return "Yakıt"
        case .insurance: return "Sigorta"
        case .other: return "Diğer"
        }
    }

    /// A single reusable color per category — shared by every chart/legend
    /// that breaks spending down by category, so the mapping never drifts
    /// between screens. Reuses the existing semantic palette rather than
    /// introducing new hues.
    var tintColor: Color {
        switch self {
        case .fuel: return AppTheme.primary
        case .maintenance: return AppTheme.warning
        case .insurance: return AppTheme.success
        case .other: return AppTheme.textTertiary
        }
    }
}
