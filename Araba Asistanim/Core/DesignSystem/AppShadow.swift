import SwiftUI

/// Cards float on the canvas with a wide, very soft indigo-tinted shadow
/// (`card`, light mode only); `primaryGlow` sits under gradient buttons.
struct AppShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

enum AppShadow {
    static let subtle = AppShadowStyle(
        color: .black.opacity(0.06),
        radius: 12,
        x: 0,
        y: 4
    )

    @MainActor
    static var card: AppShadowStyle {
        AppShadowStyle(
            color: Color(light: Color(hex: 0x3C3F8F).opacity(0.08), dark: .clear),
            radius: 18,
            x: 0,
            y: 8
        )
    }

    /// A tinted glow under the app's primary call-to-action button — one of
    /// the "truly floating elements" this file's own doc comment carves out
    /// an exception for.
    @MainActor
    static var primaryGlow: AppShadowStyle {
        AppShadowStyle(
            color: AppColors.mascotViolet.opacity(0.4),
            radius: 14,
            x: 0,
            y: 6
        )
    }
}

extension View {
    func appShadow(_ style: AppShadowStyle = AppShadow.subtle) -> some View {
        shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}
