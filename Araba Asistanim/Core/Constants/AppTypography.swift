import SwiftUI

/// Semantic font styles used across the app, built on Dynamic Type text styles
/// so content scales correctly with the user's accessibility settings.
///
/// Two styles (`heroValue`, `valueEmphasis`) use a rounded design with
/// monospaced digits — reserved for the handful of numbers that matter most
/// (mileage, cost, consumption), so they read with dashboard-like stability
/// while everything else stays on standard SF Pro. Not every value gets this
/// treatment; supporting labels stay on `body`/`subheadline`/`caption` so the
/// important numbers keep their visual weight.
enum AppTypography {
    static let largeTitle = Font.system(.largeTitle, weight: .bold)
    static let title = Font.system(.title, weight: .semibold)
    static let title2 = Font.system(.title2, weight: .semibold)
    static let title3 = Font.system(.title3, weight: .semibold)
    static let headline = Font.system(.headline, weight: .semibold)
    static let body = Font.system(.body, weight: .regular)
    static let bodyEmphasized = Font.system(.body, weight: .medium)
    static let callout = Font.system(.callout, weight: .regular)
    static let subheadline = Font.system(.subheadline, weight: .regular)
    static let footnote = Font.system(.footnote, weight: .regular)
    static let caption = Font.system(.caption, weight: .regular)
    static let captionEmphasized = Font.system(.caption, weight: .semibold)

    /// The single most important number on a screen (e.g. a hero card's mileage).
    static let heroValue = Font.system(.title, design: .rounded, weight: .bold)
    /// Secondary but still important values (e.g. statistic card figures).
    static let valueEmphasis = Font.system(.title3, design: .rounded, weight: .semibold)
}
