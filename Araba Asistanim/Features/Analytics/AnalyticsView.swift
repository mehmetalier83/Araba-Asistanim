import SwiftUI

struct AnalyticsView: View {
    @EnvironmentObject private var store: GarageStore
    @State private var timeRange: AnalyticsTimeRange = .sixMonths
    @Namespace private var rangeSwitch
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var insights: GarageInsights? {
        store.selectedVehicle.map { GarageInsights(store: store, vehicle: $0) }
    }

    private let summaryColumns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            Group {
                if let insights, insights.hasAnyData {
                    content(insights)
                } else {
                    EmptyStateView(
                        systemImage: "chart.pie.fill",
                        title: "Henüz analiz edilecek veri yok",
                        message: "Yakıt, bakım ve gider kayıtları ekledikçe harcama trendlerini burada görebileceksin."
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .appScreenBackground()
            .navigationTitle("Analiz")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    VehicleSwitcherMenu()
                }
            }
        }
    }

    private func content(_ insights: GarageInsights) -> some View {
        let months = timeRange.monthCount(history: insights.monthsOfHistory)
        let start = insights.monthStarts(count: months).first
        let monthlyExpenses = insights.monthlySpending(months: months)
        let rangeTotal = monthlyExpenses.reduce(0) { $0 + $1.value }
        let summary = [
            Statistic(
                title: months == 1 ? "Bu Ay" : "Aylık Ort.",
                value: (rangeTotal / Double(months)).rounded().formattedCurrencyTL(),
                systemImage: "banknote.fill"
            ),
            Statistic(
                title: "Ort. Yakıt Tüketimi",
                value: insights.averageConsumption(since: start)?.formattedFuelConsumption() ?? "—",
                systemImage: "fuelpump.fill"
            ),
            Statistic(
                title: "Kilometre Başı Maliyet",
                value: insights.costPerKm(since: start)?.formattedCostPerKm() ?? "—",
                systemImage: "road.lanes"
            )
        ]
        let consumption = insights.monthlyConsumption(months: months)

        return ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                timeRangePicker

                LazyVGrid(columns: summaryColumns, spacing: AppSpacing.sm) {
                    ForEach(summary) { statistic in
                        StatisticCard(statistic: statistic)
                    }
                }

                chartSection(title: "Aylık Giderler", subtitle: "Ne kadar harcıyorum?") {
                    MonthlyExpensesChartView(data: monthlyExpenses)
                }

                chartSection(title: "Yakıt Tüketimi", subtitle: "Tüketim nasıl değişiyor?") {
                    if consumption.isEmpty {
                        Text("Tüketim hesaplamak için bu aralıkta en az iki 'depo full' yakıt kaydı gerekiyor.")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppTheme.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        FuelConsumptionChartView(data: consumption)
                    }
                }

                chartSection(title: "Kategoriye Göre Giderler", subtitle: "Param nereye gidiyor?") {
                    SpendingByCategoryChartView(data: insights.breakdown(since: start))
                }
            }
            .padding(AppSpacing.md)
        }
    }

    /// A pill switch in the onboarding style: the selection slides between ranges.
    private var timeRangePicker: some View {
        HStack(spacing: 0) {
            ForEach(AnalyticsTimeRange.allCases) { range in
                Button {
                    withAnimation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.82)) { timeRange = range }
                } label: {
                    Text(range.rawValue)
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(timeRange == range ? .white : AppTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background {
                            if timeRange == range {
                                Capsule()
                                    .fill(LinearGradient.primaryButton())
                                    .matchedGeometryEffect(id: "range", in: rangeSwitch)
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(timeRange == range ? [.isButton, .isSelected] : .isButton)
            }
        }
        .padding(4)
        .background(AppTheme.cardBackground, in: Capsule())
        .overlay(Capsule().stroke(AppColors.surfaceStroke, lineWidth: 1))
        .appShadow(AppShadow.card)
        .sensoryFeedback(.selection, trigger: timeRange)
    }

    private func chartSection<Content: View>(
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text(subtitle)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                }

                content()
            }
        }
    }
}

#Preview {
    AnalyticsView()
        .environmentObject(GarageStore.preview)
}

#Preview("Dark") {
    AnalyticsView()
        .environmentObject(GarageStore.preview)
        .preferredColorScheme(.dark)
}
