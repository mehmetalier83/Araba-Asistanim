import SwiftUI

/// A full-width, filled call-to-action button used for the primary action on a screen.
/// Supports a loading state so async actions (e.g. sign in) can show progress
/// while guarding against duplicate submissions.
struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    var isEnabled: Bool = true
    var isLoading: Bool = false
    let action: () -> Void

    private var isInteractive: Bool { isEnabled && !isLoading }

    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                HStack(spacing: AppSpacing.xs) {
                    Text(title)
                        .font(.system(.headline, design: .rounded, weight: .semibold))

                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: AppSizes.iconSmall, weight: .semibold))
                    }
                }
                .opacity(isLoading ? 0 : 1)

                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
        }
        .buttonStyle(.appPressScale)
        .background(LinearGradient.primaryButton())
        .foregroundStyle(.white)
        .clipShape(Capsule())
        .appShadow(AppShadow.primaryGlow)
        .disabled(!isInteractive)
        .opacity(isEnabled ? 1 : 0.5)
        .accessibilityLabel(title)
        .accessibilityAddTraits(isLoading ? [] : .isButton)
        .accessibilityValue(isLoading ? "Yükleniyor" : "")
    }
}

#Preview {
    VStack(spacing: AppSpacing.md) {
        PrimaryButton(title: "Continue") {}
        PrimaryButton(title: "Signing In", isLoading: true) {}
        PrimaryButton(title: "Disabled", isEnabled: false) {}
    }
    .padding()
}
