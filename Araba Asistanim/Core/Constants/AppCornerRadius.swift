import CoreGraphics

/// Standardized corner radius scale used across the app's shapes and containers.
/// Kept restrained on purpose — only the Home hero card uses `hero`, so rounding
/// reads as a deliberate accent rather than a house style applied everywhere.
enum AppCornerRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let hero: CGFloat = 24
    static let pill: CGFloat = 999
}
