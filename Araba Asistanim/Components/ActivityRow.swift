import SwiftUI

/// A single row in a recent-activity or expense list: icon, title, date, and amount.
struct ActivityRow: View {
    let record: ExpenseRecord

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: record.category.systemImage)
                .font(.system(size: AppSizes.iconSmall))
                .foregroundStyle(AppTheme.primary)
                .frame(width: AppSizes.iconLarge, height: AppSizes.iconLarge)
                .background(AppTheme.primarySubtle)
                .clipShape(Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(record.title)
                    .font(AppTypography.body)
                    .foregroundStyle(AppTheme.textPrimary)

                Text(record.date.formattedDayMonthYear())
                    .font(AppTypography.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            Text(record.amount.formattedCurrencyTL())
                .font(AppTypography.headline)
                .foregroundStyle(AppTheme.textPrimary)
        }
        .padding(.vertical, AppSpacing.xxs)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(record.title), \(record.amount.formattedCurrencyTL()), \(record.date.formattedDayMonthYear())")
    }
}

#Preview {
    VStack(spacing: AppSpacing.xs) {
        ForEach(PreviewData.recentActivity) { record in
            ActivityRow(record: record)
        }
    }
    .padding()
}
