import Charts
import SwiftUI

/// A line chart of monthly fuel consumption (L/100km). Mock data only.
struct FuelConsumptionChartView: View {
    let data: [MonthlyValue]

    var body: some View {
        Chart(data) { point in
            LineMark(
                x: .value("Month", point.month),
                y: .value("Consumption", point.value)
            )
            .foregroundStyle(AppTheme.primary)
            .symbol(.circle)
            .interpolationMethod(.catmullRom)

            PointMark(
                x: .value("Month", point.month),
                y: .value("Consumption", point.value)
            )
            .foregroundStyle(AppTheme.primary)
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .environment(\.locale, Locale(identifier: "en_US"))
        .frame(height: 180)
        .accessibilityLabel("Fuel consumption chart")
        .accessibilityValue(accessibilitySummary)
    }

    private var accessibilitySummary: String {
        data.map { "\($0.month): \($0.value.formattedFuelConsumption())" }.joined(separator: ", ")
    }
}

#Preview {
    FuelConsumptionChartView(data: PreviewData.monthlyFuelConsumption)
        .padding()
}

#Preview("Dark") {
    FuelConsumptionChartView(data: PreviewData.monthlyFuelConsumption)
        .padding()
        .preferredColorScheme(.dark)
}
