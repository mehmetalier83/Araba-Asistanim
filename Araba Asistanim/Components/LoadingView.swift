import SwiftUI

/// A full-screen loading state — e.g. while restoring a session on cold launch.
/// Distinct from a button's inline loading state (see PrimaryButton).
struct LoadingView: View {
    var message: String? = nil

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            ProgressView()
                .progressViewStyle(.circular)
                .controlSize(.large)
                .tint(AppTheme.primary)

            if let message {
                Text(message)
                    .font(AppTypography.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    LoadingView(message: "Restoring your session…")
}
