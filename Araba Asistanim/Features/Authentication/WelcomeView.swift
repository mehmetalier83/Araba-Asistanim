import SwiftUI

/// The very first screen, and the root of the signed-out flow: the mascot
/// idling over the dark brand canvas with one headline, one line of support
/// and two actions. Always dark — it is a brand surface, like the app icon.
struct WelcomeView: View {
    let onGetStarted: () -> Void
    let onSignIn: () -> Void

    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            BrandGlowBackground()

            VStack(spacing: 0) {
                Spacer(minLength: AppSpacing.lg)

                CarMascot()
                    .frame(maxWidth: 220, maxHeight: 220)
                    .scaleEffect(appeared ? 1 : 0.8)
                    .opacity(appeared ? 1 : 0)

                Spacer(minLength: AppSpacing.lg)

                VStack(spacing: AppSpacing.sm) {
                    Text(AppBrand.uppercasedName)
                        .font(.system(.footnote, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(Color(hex: 0xB9B3FF))

                    Text("Aracının akıllı\nasistanı")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)

                    Text("Bakım, yakıt ve giderlerini tek yerden takip et; aklına takılanı asistana sor.")
                        .font(AppTypography.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, AppSpacing.xl)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)

                Spacer(minLength: AppSpacing.xl)

                VStack(spacing: AppSpacing.xs) {
                    GradientPillButton(title: "Başlayalım", action: onGetStarted)

                    Button(action: onSignIn) {
                        Text("Zaten hesabım var")
                            .font(.system(.headline, design: .rounded, weight: .medium))
                            .foregroundStyle(.white.opacity(0.85))
                            .frame(maxWidth: .infinity)
                            .frame(height: AppSizes.buttonHeight)
                    }
                    .buttonStyle(.appPressScale)
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.bottom, AppSpacing.sm)
                .opacity(appeared ? 1 : 0)
            }
        }
        .environment(\.colorScheme, .dark)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            withAnimation(reduceMotion ? nil : .spring(response: 0.7, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }
}

#Preview {
    WelcomeView(onGetStarted: {}, onSignIn: {})
}
