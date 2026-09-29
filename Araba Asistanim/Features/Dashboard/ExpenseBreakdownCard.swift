import Charts
import SwiftUI

/// A compact half-width stat card: total monthly spending, its trend vs. last
/// month, and a mini donut breaking it down by category. Tapping it opens the
/// full category chart on the Analytics tab.
struct ExpenseBreakdownCard: View {
    let value: String
    let changePercent: Double
    let breakdown: [(category: ExpenseCategory, total: Double)]
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            CardView {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    HStack {
                        Image(systemName: "banknote.fill")
                            .font(.system(size: AppSizes.iconSmall))
                            .foregroundStyle(AppTheme.primary)

                        Text("Aylık Giderler")
                            .font(AppTypography.footnote)
                            .foregroundStyle(AppTheme.textSecondary)
                            .lineLimit(1)

                        Spacer(minLength: 0)

                        Image(systemName: "chevron.right")
                            .font(.system(size: AppSizes.iconXSmall, weight: .semibold))
                            .foregroundStyle(AppTheme.textTertiary)
                    }

                    Text(value)
                        .font(AppTypography.valueEmphasis)
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    TrendBadge(percent: changePercent)

                    HStack(spacing: AppSpacing.sm) {
                        Chart(breakdown, id: \.category) { entry in
                            SectorMark(
                                angle: .value("Tutar", entry.total),
                                innerRadius: .ratio(0.6),
                                angularInset: 1.5
                            )
                            .foregroundStyle(entry.category.tintColor)
                            .cornerRadius(2)
                        }
                        .frame(width: 56, height: 56)
                        .accessibilityHidden(true)

                        VStack(alignment: .leading, spacing: 3) {
                            ForEach(breakdown, id: \.category) { entry in
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(entry.category.tintColor)
                                        .frame(width: 6, height: 6)

                                    Text(entry.category.displayName)
                                        .font(.system(size: 11))
                                        .foregroundStyle(AppTheme.textSecondary)
                                        .lineLimit(1)
                                }
                            }
                        }

                        Spacer(minLength: 0)
                    }
                }
            }
        }
        .buttonStyle(.appPressScale)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Aylık Giderler: \(value)")
        .accessibilityHint("Analiz sekmesinde detayları gör")
    }
}

#Preview {
    ExpenseBreakdownCard(
        value: "7,850 TL",
        changePercent: PreviewData.monthlyExpensesChangePercent,
        breakdown: PreviewData.expenseBreakdown
    ) {}
    .padding()
    .frame(width: 190)
}
