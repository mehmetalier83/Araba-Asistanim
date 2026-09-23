import Charts
import SwiftUI

/// A bar chart of monthly expenses. Mock data only.
struct MonthlyExpensesChartView: View {
    let data: [MonthlyValue]

    var body: some View {
        Chart(data) { point in
            BarMark(
                x: .value("Month", point.month),
                y: .value("Expenses", point.value)
            )
            .foregroundStyle(AppTheme.primary)
            .annotation(position: .top) {
                Text(point.value, format: .number.precision(.fractionLength(0)))
                    .font(.caption2)
                    .foregroundStyle(AppTheme.textSecondary)
                    .accessibilityHidden(true)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .environment(\.locale, Locale(identifier: "en_US"))
        .frame(height: 180)
        .accessibilityLabel("Monthly expenses chart")
        .accessibilityValue(accessibilitySummary)
    }

    private var accessibilitySummary: String {
        data.map { "\($0.month): \($0.value.formattedCurrencyTL())" }.joined(separator: ", ")
    }
}

#Preview {
    MonthlyExpensesChartView(data: PreviewData.monthlyExpenses)
        .padding()
}

#Preview("Dark") {
    MonthlyExpensesChartView(data: PreviewData.monthlyExpenses)
        .padding()
        .preferredColorScheme(.dark)
}
