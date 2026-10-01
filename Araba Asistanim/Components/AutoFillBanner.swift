import SwiftUI

/// A dismissible notice shown after a receipt scan pre-fills form fields —
/// the camera can misread a blurry or faded receipt, so this explicitly
/// tells the person to check the values rather than implying they're final.
struct AutoFillBanner: View {
    @Binding var isPresented: Bool

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.xs) {
            Image(systemName: "sparkles")
                .font(.system(size: AppSizes.iconSmall))
                .foregroundStyle(AppTheme.primary)
                .accessibilityHidden(true)

            Text("Fişten tutar ve tür otomatik dolduruldu. Kontrol etmeyi unutma.")
                .font(AppTypography.caption)
                .foregroundStyle(AppTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            Button {
                isPresented = false
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: AppSizes.iconXSmall, weight: .semibold))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .accessibilityLabel("Bildirimi kapat")
        }
        .padding(AppSpacing.sm)
        .background(AppTheme.primarySubtle)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    AutoFillBanner(isPresented: .constant(true))
        .padding()
}
