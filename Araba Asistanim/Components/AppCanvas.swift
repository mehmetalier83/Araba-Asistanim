import SwiftUI

/// The page background for every in-app screen, matching onboarding and sign
/// in: deep navy with soft indigo/violet glows in dark mode, lavender with
/// faint glows in light mode. Static (no drift) so long screens stay calm.
struct AppCanvas: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let isDark = colorScheme == .dark
        ZStack {
            if isDark {
                LinearGradient(
                    colors: [Color(hex: 0x17143F), Color(hex: 0x0D0C24), Color(hex: 0x07070F)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            } else {
                AppColors.canvas
            }

            RadialGradient(
                colors: [AppColors.mascotViolet.opacity(isDark ? 0.35 : 0.14), .clear],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 420
            )

            RadialGradient(
                colors: [AppColors.mascotIndigo.opacity(isDark ? 0.22 : 0.08), .clear],
                center: UnitPoint(x: 0, y: 0.55),
                startRadius: 0,
                endRadius: 380
            )
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

extension View {
    /// Puts `AppCanvas` behind a screen (and hides a List's own background).
    func appScreenBackground() -> some View {
        scrollContentBackground(.hidden)
            .background { AppCanvas() }
    }

    /// The shared card surface: white / deep-indigo fill, large continuous
    /// corners, a hairline outline in dark mode and a soft shadow in light mode.
    /// Padding is left to the caller.
    func appCard(cornerRadius: CGFloat = AppCornerRadius.card) -> some View {
        background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(AppColors.surfaceStroke, lineWidth: 1)
            )
            .appShadow(AppShadow.card)
    }
}
