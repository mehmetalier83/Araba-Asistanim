import SwiftUI

/// A labeled rule separating two alternative actions — social sign-in above,
/// the email/password form below.
struct OrDivider: View {
    var label: String = "veya"

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Rectangle()
                .fill(AppTheme.border)
                .frame(height: 1)

            Text(label)
                .font(AppTypography.footnote)
                .foregroundStyle(AppTheme.textSecondary)

            Rectangle()
                .fill(AppTheme.border)
                .frame(height: 1)
        }
    }
}

#Preview {
    OrDivider()
        .padding()
}
