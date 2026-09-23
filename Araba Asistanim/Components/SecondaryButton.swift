import SwiftUI

/// A low-emphasis action alongside a PrimaryButton. Uses a soft tinted fill
/// rather than an outline — avoids adding another border to the screen while
/// still reading clearly as a distinct, tappable action.
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
                    .font(AppTypography.headline)
                    .opacity(isLoading ? 0 : 1)

                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(AppTheme.primary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: AppSizes.buttonHeight)
        }
        .buttonStyle(.appPressScale)
        .foregroundStyle(AppTheme.primary)
        .background(AppTheme.primarySubtle)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous))
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
