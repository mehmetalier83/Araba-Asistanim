import CoreGraphics

/// Standardized corner radius scale used across the app's shapes and containers.
/// Cards use `card`; `hero` is for large gradient hero surfaces.
enum AppCornerRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let card: CGFloat = 22
    static let hero: CGFloat = 28
    static let pill: CGFloat = 999
}
