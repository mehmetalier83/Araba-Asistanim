import CoreGraphics

/// Standardized spacing scale used across the app's layouts. Deliberately small
/// and consistent (4/8/12/16/20/24/32) so the interface reads with a steady
/// rhythm instead of one-off values like 13 or 19.
enum AppSpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    /// Reserved for rare hero-scale breathing room (e.g. the Welcome screen).
    static let hero: CGFloat = 48
}
