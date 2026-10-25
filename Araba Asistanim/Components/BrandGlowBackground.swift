import SwiftUI

/// The deep navy → violet canvas behind Welcome and onboarding: a vertical
/// gradient with two large blurred glows that drift slowly. `accent` tints the
/// upper glow so each onboarding page can shift the mood. Still under Reduce Motion.
struct BrandGlowBackground: View {
    var accent: Color = AppColors.mascotViolet

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { context in
            let t = reduceMotion ? 0 : context.date.timeIntervalSinceReferenceDate
            ZStack {
                LinearGradient(
                    colors: [Color(hex: 0x1A1650), Color(hex: 0x0B0C24), Color(hex: 0x05060F)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                Circle()
                    .fill(accent.opacity(0.55))
                    .frame(width: 380, height: 380)
                    .blur(radius: 120)
                    .offset(x: 110 + cos(t / 4) * 30, y: -260 + sin(t / 5) * 26)

                Circle()
                    .fill(AppColors.mascotIndigo.opacity(0.4))
                    .frame(width: 320, height: 320)
                    .blur(radius: 120)
                    .offset(x: -130 + sin(t / 6) * 30, y: 60 + cos(t / 4) * 32)
            }
            .animation(.easeInOut(duration: 0.8), value: accent)
        }
        .ignoresSafeArea()
    }
}

/// The primary call-to-action on the dark brand canvas: a full-width pill in
/// the mascot gradient with a soft violet glow.
struct GradientPillButton: View {
    let title: String
    var systemImage: String? = "arrow.right"
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.xs) {
                Text(title)
                if let systemImage {
                    Image(systemName: systemImage)
                        .contentTransition(.symbolEffect(.replace))
                }
            }
            .font(.system(.headline, design: .rounded, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(LinearGradient.mascot(startPoint: .leading, endPoint: .trailing), in: Capsule())
            .overlay(Capsule().stroke(.white.opacity(0.18), lineWidth: 1))
            .shadow(color: AppColors.mascotViolet.opacity(0.45), radius: 18, y: 8)
        }
        .buttonStyle(.appPressScale)
    }
}
