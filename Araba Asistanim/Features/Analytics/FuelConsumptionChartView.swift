import Charts
import SwiftUI

/// A line chart of monthly fuel consumption (L/100km).
struct FuelConsumptionChartView: View {
    let data: [MonthlyValue]

    var body: some View {
        Chart(data) { point in
            AreaMark(
                x: .value("Ay", point.month),
                y: .value("Tüketim", point.value)
            )
            .foregroundStyle(
                LinearGradient(colors: [AppColors.mascotViolet.opacity(0.28), AppColors.mascotViolet.opacity(0)], startPoint: .top, endPoint: .bottom)
            )
            .interpolationMethod(.catmullRom)

            LineMark(
                x: .value("Ay", point.month),
                y: .value("Tüketim", point.value)
            )
            .foregroundStyle(LinearGradient.primaryButton())
            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
            .symbol(.circle)
            .interpolationMethod(.catmullRom)

            PointMark(
                x: .value("Ay", point.month),
                y: .value("Tüketim", point.value)
            )
            .foregroundStyle(AppColors.mascotViolet)
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .environment(\.locale, Locale(identifier: "en_US"))
        .frame(height: 180)
        .accessibilityLabel("Yakıt tüketimi grafiği")
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
