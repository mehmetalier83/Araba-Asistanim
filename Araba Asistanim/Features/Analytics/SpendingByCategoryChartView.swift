import Charts
import SwiftUI

/// Answers "where is my money going?" — a compact donut plus a legend list,
/// rather than a bar chart that would just repeat MonthlyExpensesChartView.
struct SpendingByCategoryChartView: View {
    let data: [(category: ExpenseCategory, total: Double)]

    private var total: Double { data.reduce(0) { $0 + $1.total } }

    var body: some View {
        if data.isEmpty {
            EmptyStateView(
                systemImage: "chart.pie",
                title: "Henüz gider yok",
                message: "Gider eklediğinde kategoriye göre dağılım burada görünecek."
            )
        } else {
            HStack(spacing: AppSpacing.lg) {
                Chart(data, id: \.category) { entry in
                    SectorMark(
                        angle: .value("Tutar", entry.total),
                        innerRadius: .ratio(0.65),
                        angularInset: 1.5
                    )
                    .foregroundStyle(entry.category.tintColor)
                    .cornerRadius(3)
                }
                .chartBackground { _ in
                    VStack(spacing: 0) {
                        Text("Toplam")
                            .font(.caption2)
                            .foregroundStyle(AppTheme.textSecondary)
                        Text(total.formattedCurrencyTL())
                            .font(.system(.caption, design: .rounded, weight: .bold))
                            .foregroundStyle(AppTheme.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                    }
                    .frame(width: 70)
                }
                .frame(width: 130, height: 130)
                .accessibilityLabel("Kategoriye göre giderler")
                .accessibilityValue(accessibilitySummary)

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    ForEach(data, id: \.category) { entry in
                        HStack(spacing: AppSpacing.xs) {
                            Circle()
                                .fill(entry.category.tintColor)
                                .frame(width: 8, height: 8)
                                .accessibilityHidden(true)

                            Text(entry.category.displayName)
                                .font(AppTypography.subheadline)
                                .foregroundStyle(AppTheme.textPrimary)

                            Spacer()

                            Text(entry.total.formattedCurrencyTL())
                                .font(AppTypography.footnote)
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                    }
                }
            }
        }
    }

    private var accessibilitySummary: String {
        data.map { "\($0.category.displayName): \($0.total.formattedCurrencyTL())" }.joined(separator: ", ")
    }
}

#Preview {
    SpendingByCategoryChartView(data: PreviewData.expenseBreakdown)
        .padding()
}

#Preview("Dark") {
    SpendingByCategoryChartView(data: PreviewData.expenseBreakdown)
        .padding()
        .preferredColorScheme(.dark)
}
