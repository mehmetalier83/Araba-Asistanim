import Charts
import SwiftUI

/// A compact half-width stat card: current fuel consumption, its trend vs. last
/// month, and a tiny sparkline-style bar chart of the last few months. Tapping
/// it opens the full Fuel Consumption chart on the Analytics tab — a real
/// destination, not a decorative chevron.
struct FuelTrendCard: View {
    let value: String
    let changePercent: Double
    let history: [MonthlyValue]
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            CardView {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    HStack {
                        Image(systemName: "fuelpump.fill")
                            .font(.system(size: AppSizes.iconSmall))
                            .foregroundStyle(AppTheme.primary)

                        Text("Yakıt Tüketimi")
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

                    Chart(history) { point in
                        BarMark(
                            x: .value("Ay", point.month),
                            y: .value("Tüketim", point.value)
                        )
                        .foregroundStyle(AppTheme.primary.opacity(0.85))
                        .cornerRadius(2)
                    }
                    .chartYAxis(.hidden)
                    .chartXAxis {
                        AxisMarks { _ in
                            AxisValueLabel()
                                .font(.system(size: 9))
                                .foregroundStyle(AppTheme.textTertiary)
                        }
                    }
                    .frame(height: 56)
                }
            }
        }
        .buttonStyle(.appPressScale)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Yakıt Tüketimi: \(value)")
        .accessibilityHint("Analiz sekmesinde detayları gör")
    }
}

#Preview {
    FuelTrendCard(
        value: "7.8 L/100 km",
        changePercent: PreviewData.fuelConsumptionChangePercent,
        history: PreviewData.monthlyFuelConsumption
    ) {}
    .padding()
    .frame(width: 190)
}
