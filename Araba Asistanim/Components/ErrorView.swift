import SwiftUI

/// An inline, friendly error message — for form field validation or a small
/// banner above a primary action. Never displays raw/technical error text;
/// callers are responsible for mapping errors to user-facing copy first.
struct ErrorView: View {
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.xs) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: AppSizes.iconXSmall))
                .foregroundStyle(AppTheme.error)
                .accessibilityHidden(true)

            Text(message)
                .font(AppTypography.footnote)
                .foregroundStyle(AppTheme.error)
        }
        .accessibilityElement(children: .combine)
    }
}

/// A full-screen error state with a retry action — for a screen that failed to
/// load entirely (not used for form validation; see ErrorView for that).
struct FullScreenErrorView: View {
    let title: String
    let message: String
    var retryTitle: String = "Try Again"
    var onRetry: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: AppSizes.iconLarge))
                .foregroundStyle(AppTheme.warning)
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

            if let onRetry {
                SecondaryButton(title: retryTitle, action: onRetry)
                    .frame(maxWidth: 220)
            }
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    VStack(spacing: AppSpacing.lg) {
        ErrorView(message: "Enter a valid email address.")
        FullScreenErrorView(
            title: "Something went wrong",
            message: "We couldn't load your data. Please try again.",
            onRetry: {}
        )
    }
    .padding()
}
