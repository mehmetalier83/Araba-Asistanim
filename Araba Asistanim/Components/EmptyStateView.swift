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
        VStack(spacing: AppSpacing.lg) {
            illustration

            VStack(spacing: AppSpacing.xxs) {
                Text(title)
                    .font(AppTypography.title3)
                    .foregroundStyle(AppTheme.textPrimary)

                Text(message)
                    .font(AppTypography.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle, let action {
                PrimaryButton(title: actionTitle, icon: "arrow.right", action: action)
                    .frame(maxWidth: 260)
                    .padding(.top, AppSpacing.xs)
            }
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    private var illustration: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [AppTheme.primary.opacity(0.18), AppTheme.primary.opacity(0.02)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 70
                    )
                )
                .frame(width: 140, height: 140)

            Image(systemName: "sparkle")
                .font(.system(size: 12))
                .foregroundStyle(AppTheme.primary.opacity(0.5))
                .offset(x: -44, y: -36)

            Image(systemName: "sparkle")
                .font(.system(size: 9))
                .foregroundStyle(AppTheme.primary.opacity(0.4))
                .offset(x: 46, y: -16)

            Image(systemName: systemImage)
                .font(.system(size: AppSizes.iconHero + 8))
                .foregroundStyle(AppTheme.primary)
        }
        .accessibilityHidden(true)
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
