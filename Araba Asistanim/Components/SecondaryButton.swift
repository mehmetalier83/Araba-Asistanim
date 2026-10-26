import SwiftUI

/// A low-emphasis action alongside a PrimaryButton: a card-colored pill with a
/// hairline outline, so it reads as tappable without competing with the gradient.
struct SecondaryButton: View {
    let title: String
    var isEnabled: Bool = true
    var isLoading: Bool = false
    let action: () -> Void

    private var isInteractive: Bool { isEnabled && !isLoading }

    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                Text(title)
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .opacity(isLoading ? 0 : 1)

                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(AppTheme.primary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
        }
        .buttonStyle(.appPressScale)
        .foregroundStyle(AppTheme.primary)
        .background(AppTheme.cardBackground, in: Capsule())
        .overlay(Capsule().stroke(AppTheme.primary.opacity(0.3), lineWidth: 1))
        .disabled(!isInteractive)
        .opacity(isEnabled ? 1 : 0.5)
        .accessibilityLabel(title)
    }
}

#Preview {
    VStack(spacing: AppSpacing.md) {
        SecondaryButton(title: "Cancel") {}
        SecondaryButton(title: "Disabled", isEnabled: false) {}
    }
    .padding()
}
