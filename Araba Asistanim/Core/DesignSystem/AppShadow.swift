import SwiftUI

/// Shadow is used sparingly by design — most surfaces separate themselves with a
/// flat background-color change (grouped-list style), not elevation. Reserve this
/// for the one or two truly floating elements per screen (e.g. the Home hero card).
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
}

extension View {
    func appShadow(_ style: AppShadowStyle = AppShadow.subtle) -> some View {
        shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}
