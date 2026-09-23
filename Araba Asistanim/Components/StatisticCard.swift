import SwiftUI

/// A compact card showing a single labeled statistic with an icon. Used where
/// statistics genuinely stand alone (e.g. Analytics summary row); on Home,
/// related statistics are grouped into one card instead of a grid of these —
/// see VehicleHealthCard.
struct StatisticCard: View {
    let statistic: Statistic

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Image(systemName: statistic.systemImage)
                    .font(.system(size: AppSizes.iconSmall))
                    .foregroundStyle(AppTheme.primary)
                    .accessibilityHidden(true)

                Text(statistic.value)
                    .font(AppTypography.valueEmphasis)
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)

                Text(statistic.title)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
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
