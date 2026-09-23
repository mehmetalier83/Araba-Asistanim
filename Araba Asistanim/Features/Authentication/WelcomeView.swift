import SwiftUI

/// The very first screen. Full-bleed dark surface (matching the Home hero
/// card's treatment) so the brand feels premium and automotive from the first
/// frame, rather than a generic white SaaS landing page.
struct WelcomeView: View {
    let onGetStarted: () -> Void
    let onSignIn: () -> Void

    var body: some View {
        ZStack {
            backgroundSurface

            Image(systemName: "car.side.fill")
                .font(.system(size: 320))
                .foregroundStyle(.white.opacity(0.05))
                .frame(width: 320, height: 320)
                .offset(x: 90, y: -120)
                .accessibilityHidden(true)
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                Spacer()

                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        Text("CARLOG AI")
                            .font(.system(.footnote, weight: .bold))
                            .tracking(2)
                            .foregroundStyle(AppColors.accentDarkOnDark)

                        Text("Know your car.\nUnderstand your costs.")
                            .font(.system(.largeTitle, weight: .bold))
                            .foregroundStyle(.white)
                    }

                    Text("Track maintenance, fuel, expenses and your vehicle history in one place.")
                        .font(AppTypography.body)
                        .foregroundStyle(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, AppSpacing.lg)

                Spacer()

                VStack(spacing: AppSpacing.sm) {
                    Button(action: onGetStarted) {
                        Text("Get Started")
                            .font(AppTypography.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: AppSizes.buttonHeight)
                    }
                    .buttonStyle(.appPressScale)
                    .foregroundStyle(Color(hex: 0x141A26))
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous))

                    Button(action: onSignIn) {
                        Text("I Already Have an Account")
                            .font(AppTypography.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: AppSizes.buttonHeight)
                    }
                    .buttonStyle(.appPressScale)
                    .foregroundStyle(.white)
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.bottom, AppSpacing.md)
            }
        }
        .background(Color(hex: 0x05070C))
        .ignoresSafeArea(edges: .top)
    }

    private var backgroundSurface: some View {
        LinearGradient(
            colors: [Color(hex: 0x24304A), Color(hex: 0x05070C)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

private extension AppColors {
    /// A brighter accent tint reserved for use over the always-dark Welcome
    /// surface, independent of the system light/dark appearance.
    static let accentDarkOnDark = Color(hex: 0x8FB0FF)
}

#Preview {
    WelcomeView(onGetStarted: {}, onSignIn: {})
}
