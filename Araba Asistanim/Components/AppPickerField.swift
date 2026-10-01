import SwiftUI

/// A field styled like AppTextField but for picking from a fixed set of
/// options rather than free typing — visually consistent with text fields
/// (same label, height, corner radius) so a form can mix both without feeling
/// inconsistent. Purely presentational: wrap it in a `Menu` (or any other
/// picker trigger) at the call site.
struct AppPickerField: View {
    let title: String
    let placeholder: String
    let selection: String?
    var icon: String? = nil
    var isEnabled: Bool = true
    var errorMessage: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text(title)
                .font(AppTypography.footnote)
                .foregroundStyle(AppTheme.textSecondary)

            HStack(spacing: AppSpacing.xs) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: AppSizes.iconSmall))
                        .foregroundStyle(AppTheme.textSecondary)
                        .frame(width: AppSizes.iconMedium)
                        .accessibilityHidden(true)
                }

                Text(selection ?? placeholder)
                    .font(AppTypography.body)
                    .foregroundStyle(selection == nil ? AppTheme.textTertiary : AppTheme.textPrimary)
                    .lineLimit(1)

                Spacer(minLength: AppSpacing.xs)

                Image(systemName: "chevron.down")
                    .font(.system(size: AppSizes.iconXSmall, weight: .semibold))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .padding(.horizontal, AppSpacing.sm)
            .frame(height: AppSizes.buttonHeight)
            .background(AppTheme.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous)
                    .stroke(AppTheme.error, lineWidth: errorMessage != nil ? 1.5 : 0)
            )
            .opacity(isEnabled ? 1 : 0.5)

            if let errorMessage {
                ErrorView(message: errorMessage)
            }
        }
        .animation(AppAnimation.fast, value: errorMessage)
    }
}

#Preview {
    VStack(spacing: AppSpacing.md) {
        AppPickerField(title: "Marka", placeholder: "Marka seç", selection: nil)
        AppPickerField(title: "Model", placeholder: "Önce marka seç", selection: nil, isEnabled: false)
        AppPickerField(title: "Marka", placeholder: "Marka seç", selection: "BMW")
        AppPickerField(title: "Marka", placeholder: "Marka seç", selection: nil, errorMessage: "Marka seç.")
    }
    .padding()
}
