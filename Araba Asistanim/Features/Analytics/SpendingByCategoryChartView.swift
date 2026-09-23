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
                title: "No expenses yet",
                message: "Spending by category will appear here once you log expenses."
            )
        } else {
            HStack(spacing: AppSpacing.lg) {
                Chart(data, id: \.category) { entry in
                    SectorMark(
                        angle: .value("Amount", entry.total),
                        innerRadius: .ratio(0.65),
                        angularInset: 1.5
                    )
                    .foregroundStyle(color(for: entry.category))
                    .cornerRadius(3)
                }
                .frame(width: 120, height: 120)
                .accessibilityLabel("Spending by category")
                .accessibilityValue(accessibilitySummary)

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    ForEach(data, id: \.category) { entry in
                        HStack(spacing: AppSpacing.xs) {
                            Circle()
                                .fill(color(for: entry.category))
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

    private func color(for category: ExpenseCategory) -> Color {
        switch category {
        case .maintenance: return AppTheme.primary
        case .fuel: return AppTheme.warning
        case .other: return AppTheme.success
        }
    }
}

private extension ExpenseCategory {
    var displayName: String {
        switch self {
        case .maintenance: return "Maintenance"
        case .fuel: return "Fuel"
        case .other: return "Other"
        }
    }
}

#Preview {
    SpendingByCategoryChartView(data: PreviewData.spendingByCategory)
        .padding()
}

#Preview("Dark") {
    SpendingByCategoryChartView(data: PreviewData.spendingByCategory)
        .padding()
        .preferredColorScheme(.dark)
}
