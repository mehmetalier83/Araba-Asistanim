import SwiftUI

struct AnalyticsView: View {
    @State private var timeRange: AnalyticsTimeRange = .sixMonths

    /// Only the seeded demo account has sample history to chart — every
    /// other account starts with nothing recorded yet, so the charts
    /// themselves would just be empty axes with no story to tell.
    private let hasData = AppSession.isDemoAccount

    private let monthlyExpenses = AppSession.isDemoAccount ? PreviewData.monthlyExpenses : []
    private let monthlyFuelConsumption = AppSession.isDemoAccount ? PreviewData.monthlyFuelConsumption : []
    private let expenseBreakdown = AppSession.isDemoAccount ? PreviewData.expenseBreakdown : []
    private let summary = AppSession.isDemoAccount ? PreviewData.analyticsSummary : []

    private let summaryColumns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            Group {
                if hasData {
                    content
                } else {
                    EmptyStateView(
                        systemImage: "chart.pie.fill",
                        title: "Henüz analiz edilecek veri yok",
                        message: "Yakıt, bakım ve gider kayıtları ekledikçe harcama trendlerini burada görebileceksin."
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .background(AppTheme.groupedBackground)
            .navigationTitle("Analiz")
        }
    }

    private var content: some View {
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
