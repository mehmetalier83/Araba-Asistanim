import Charts
import SwiftUI

/// A bar chart of monthly expenses.
struct MonthlyExpensesChartView: View {
    let data: [MonthlyValue]

    var body: some View {
        Chart(data) { point in
            BarMark(
                x: .value("Ay", point.month),
                y: .value("Giderler", point.value)
            )
            .foregroundStyle(LinearGradient.mascot(startPoint: .bottom, endPoint: .top))
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .annotation(position: .top) {
                Text(point.value, format: .number.precision(.fractionLength(0)))
                    .font(.caption2)
                    .foregroundStyle(AppTheme.textSecondary)
                    .opacity(data.count <= 6 ? 1 : 0)
                    .accessibilityHidden(true)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .environment(\.locale, Locale(identifier: "en_US"))
        .frame(height: 180)
        .accessibilityLabel("Aylık giderler grafiği")
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
