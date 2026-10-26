import SwiftUI

/// Central color palette for the app.
///
/// Backgrounds follow the brand canvas (lavender / deep navy) with white or
/// indigo cards, see `AppColors`. Text and separators stay on Apple's dynamic
/// system colors, which respond automatically to Increased Contrast. Brand colors (accent,
/// success, warning, danger) are defined independently per-appearance in
/// `AppColors` so dark mode feels designed rather than inverted.
enum AppTheme {
    static let primary = AppColors.accent
    static let primarySubtle = AppColors.accentSubtle
    static let secondary = Color(.secondaryLabel)

    static let background = AppColors.canvas
    static let groupedBackground = AppColors.canvas
    static let secondaryBackground = AppColors.field
    static let cardBackground = AppColors.surface
    static let elevatedBackground = AppColors.surface

    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    static let textTertiary = Color(.tertiaryLabel)

    static let border = Color(.separator)
    static let borderOpaque = Color(.opaqueSeparator)

    static let success = AppColors.success
    static let successSubtle = AppColors.successSubtle
    static let warning = AppColors.warning
    static let warningSubtle = AppColors.warningSubtle
    static let error = AppColors.danger
    static let errorSubtle = AppColors.dangerSubtle

    /// Extra accents used only by the expense-category palette (see
    /// `ExpenseCategory.tintColor`) — not general-purpose semantic roles.
    static let categoryTeal = AppColors.categoryTeal
    static let categoryPurple = AppColors.categoryPurple
}
