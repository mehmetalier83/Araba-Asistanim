import SwiftUI

/// Central color palette for the app.
///
/// Neutrals (backgrounds, text, separators) intentionally stay on Apple's dynamic
/// system colors: they already ship with carefully tuned, non-inverted dark-mode
/// variants and respond automatically to Increased Contrast. Brand colors (accent,
/// success, warning, danger) are defined independently per-appearance in
/// `AppColors` so dark mode feels designed rather than inverted.
enum AppTheme {
    static let primary = AppColors.accent
    static let primarySubtle = AppColors.accentSubtle
    static let secondary = Color(.secondaryLabel)

    static let background = Color(.systemBackground)
    static let groupedBackground = Color(.systemGroupedBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let cardBackground = Color(.secondarySystemBackground)
    static let elevatedBackground = Color(.tertiarySystemBackground)

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
}
