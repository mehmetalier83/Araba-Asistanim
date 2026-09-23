import SwiftUI

/// A generic placeholder shown in place of a list when there is no data to
/// display. Written to feel helpful and inviting, not like an error state.
struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: AppSizes.iconHero))
                .foregroundStyle(AppTheme.primary)
                .accessibilityHidden(true)

            VStack(spacing: AppSpacing.xxs) {
                Text(title)
                    .font(AppTypography.headline)
                    .foregroundStyle(AppTheme.textPrimary)

                Text(message)
                    .font(AppTypography.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle, let action {
                PrimaryButton(title: actionTitle, action: action)
                    .frame(maxWidth: 240)
                    .padding(.top, AppSpacing.xs)
            }
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    EmptyStateView(
        systemImage: "car.2.fill",
        title: "Your garage is empty",
        message: "Add your first vehicle to start tracking maintenance, fuel and expenses.",
        actionTitle: "Add Vehicle"
    ) {}
}
