import SwiftUI

struct AnalyticsView: View {
    @State private var timeRange: AnalyticsTimeRange = .sixMonths

    private let monthlyExpenses = PreviewData.monthlyExpenses
    private let monthlyFuelConsumption = PreviewData.monthlyFuelConsumption
    private let expenseBreakdown = PreviewData.expenseBreakdown
    private let summary = PreviewData.analyticsSummary

    private let summaryColumns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    timeRangePicker

                    LazyVGrid(columns: summaryColumns, spacing: AppSpacing.sm) {
                        ForEach(summary) { statistic in
                            StatisticCard(statistic: statistic)
                        }
                    }

                    chartSection(title: "Aylık Giderler", subtitle: "Ne kadar harcıyorum?") {
                        MonthlyExpensesChartView(data: timeRange.filter(monthlyExpenses))
                    }

                    chartSection(title: "Yakıt Tüketimi", subtitle: "Tüketim nasıl değişiyor?") {
                        FuelConsumptionChartView(data: timeRange.filter(monthlyFuelConsumption))
                    }

                    chartSection(title: "Kategoriye Göre Giderler", subtitle: "Param nereye gidiyor?") {
                        SpendingByCategoryChartView(data: expenseBreakdown)
                    }
                }
                .padding(AppSpacing.md)
            }
            .background(AppTheme.groupedBackground)
            .navigationTitle("Analiz")
        }
    }

    private var timeRangePicker: some View {
        Picker("Zaman Aralığı", selection: $timeRange.animation(AppAnimation.fast)) {
            ForEach(AnalyticsTimeRange.allCases) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
    }

    private func chartSection<Content: View>(
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTypography.headline)
                    .foregroundStyle(AppTheme.textPrimary)
                Text(subtitle)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            CardView {
                content()
            }
        }
    }
}

#Preview {
    AnalyticsView()
}

#Preview("Dark") {
    AnalyticsView()
        .preferredColorScheme(.dark)
}
