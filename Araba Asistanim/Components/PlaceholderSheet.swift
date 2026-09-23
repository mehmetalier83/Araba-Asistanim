import SwiftUI

/// A generic "coming soon" sheet used to stand in for screens whose real
/// functionality (record creation, backend integration) isn't implemented yet.
struct PlaceholderSheet: View {
    @Environment(\.dismiss) private var dismiss

    let systemImage: String
    let title: String
    let message: String

    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.md) {
                Spacer()

                Image(systemName: systemImage)
                    .font(.system(size: AppSizes.iconLarge * 1.5))
                    .foregroundStyle(AppTheme.primary)
                    .accessibilityHidden(true)

                Text(title)
                    .font(AppTypography.title2)
                    .foregroundStyle(AppTheme.textPrimary)

                Text(message)
                    .font(AppTypography.body)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.lg)

                Spacer()

                PrimaryButton(title: "Got it") {
                    dismiss()
                }
                .padding(.horizontal, AppSpacing.lg)
            }
            .padding(.vertical, AppSpacing.lg)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    PlaceholderSheet(
        systemImage: "fuelpump.fill",
        title: "Add Fuel",
        message: "Fuel entry creation isn't implemented yet. This will be available in a future phase."
    )
}
