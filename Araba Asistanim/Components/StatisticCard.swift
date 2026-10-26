import SwiftUI

/// A compact card showing a single labeled statistic with an icon. Used where
/// statistics genuinely stand alone (e.g. the Analytics summary row).
struct StatisticCard: View {
    let statistic: Statistic

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Image(systemName: statistic.systemImage)
                .font(.system(size: AppSizes.iconXSmall, weight: .semibold))
                .foregroundStyle(AppTheme.primary)
                .frame(width: 32, height: 32)
                .background(AppTheme.primarySubtle, in: Circle())
                .padding(.bottom, AppSpacing.xxs)
                .accessibilityHidden(true)

            Text(statistic.value)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text(statistic.title)
                .font(AppTypography.caption)
                .foregroundStyle(AppTheme.textSecondary)
                .lineLimit(2, reservesSpace: true)
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(statistic.title): \(statistic.value)")
    }
}

#Preview {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.sm) {
        ForEach(PreviewData.analyticsSummary) { statistic in
            StatisticCard(statistic: statistic)
        }
    }
    .padding()
}

#Preview("Dark") {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.sm) {
        ForEach(PreviewData.analyticsSummary) { statistic in
            StatisticCard(statistic: statistic)
        }
    }
    .padding()
    .preferredColorScheme(.dark)
}
