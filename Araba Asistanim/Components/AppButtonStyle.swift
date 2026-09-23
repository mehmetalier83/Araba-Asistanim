import SwiftUI

/// Shared press feedback for every button in the app: a small scale-down on
/// press, nothing more. Respects Reduce Motion by skipping the animation
/// (the scale still applies instantly, so touch feedback isn't lost).
struct AppPressScaleStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(reduceMotion ? nil : AppAnimation.fast, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == AppPressScaleStyle {
    static var appPressScale: AppPressScaleStyle { AppPressScaleStyle() }
}
