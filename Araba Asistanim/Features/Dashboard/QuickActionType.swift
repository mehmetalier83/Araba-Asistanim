import SwiftUI

/// A quick-action shortcut on the Home dashboard. Selecting one shows a
/// placeholder sheet in this phase — no record is actually created yet.
enum QuickActionType: String, CaseIterable, Identifiable {
    case addFuel
    case addExpense
    case addMaintenance

    var id: String { rawValue }

    var title: String {
        switch self {
        case .addFuel: return "Yakıt Ekle"
        case .addExpense: return "Gider Ekle"
        case .addMaintenance: return "Bakım Ekle"
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
        "\(title) özelliği henüz eklenmedi. Backend entegrasyonu tamamlandığında kayıt oluşturma kullanılabilir olacak."
    }

    /// Each action gets a distinct tint (reusing the existing semantic
    /// palette) so the quick-actions row reads as a set of clearly different
    /// shortcuts rather than three identical blue buttons.
    var tintColor: Color {
        switch self {
        case .addFuel: return AppTheme.primary
        case .addExpense: return AppTheme.success
        case .addMaintenance: return AppTheme.warning
        }
    }
}
