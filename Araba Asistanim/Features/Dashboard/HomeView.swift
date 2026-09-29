import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject private var appState: AppState
    @State private var path = NavigationPath()
    @State private var isShowingNotifications = false

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    header

                    VehicleHeroCard(vehicle: viewModel.vehicle) {
                        path.append(HomeRoute.vehicleDetail(viewModel.vehicle))
                    }

                    quickActions

                    statRow

                    if let item = viewModel.nextMaintenanceItem {
                        nextServiceBanner(item)
                    }

                    recentActivity
                    aiInsight
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.bottom, AppSpacing.xl)
            }
            .background(AppTheme.groupedBackground)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case .settings:
                    SettingsView()
                case .vehicleDetail(let vehicle):
                    VehicleDetailView(vehicle: vehicle)
                }
            }
            .sheet(item: $viewModel.activeQuickAction) { action in
                PlaceholderSheet(
                    systemImage: action.systemImage,
                    title: action.title,
                    message: action.placeholderMessage
                )
            }
            .sheet(isPresented: $viewModel.isShowingInsightDetail) {
                PlaceholderSheet(
                    systemImage: "sparkles",
                    title: "Yakıt Tüketimi Analizi",
                    message: viewModel.aiInsightDetail
                )
            }
            .sheet(isPresented: $isShowingNotifications) {
                PlaceholderSheet(
                    systemImage: "bell.fill",
                    title: "Bildirimler",
                    message: "Bildirimler henüz eklenmedi. Bu özellik ileride kullanılabilir olacak."
                )
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Günaydın,")
                    .font(AppTypography.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)

                Text("\(viewModel.vehicle.make)'in hazır 👋")
                    .font(AppTypography.title)
                    .foregroundStyle(AppTheme.textPrimary)
            }

            Spacer()

            HStack(spacing: AppSpacing.xs) {
                ZStack(alignment: .topTrailing) {
                    IconButton(systemImage: "bell.fill", accessibilityLabel: "Bildirimler") {
                        isShowingNotifications = true
                    }
                    BadgeView()
                        .offset(x: -6, y: 6)
                        .allowsHitTesting(false)
                }

                IconButton(systemImage: "gearshape.fill", accessibilityLabel: "Ayarlar") {
                    path.append(HomeRoute.settings)
                }
            }
        }
        .padding(.top, AppSpacing.xs)
    }

    // MARK: - Quick actions

    private var quickActions: some View {
        HStack(spacing: 0) {
            ForEach(QuickActionType.allCases) { action in
                Button {
                    viewModel.selectQuickAction(action)
                } label: {
                    VStack(spacing: AppSpacing.xxs) {
                        Image(systemName: action.systemImage)
                            .font(.system(size: AppSizes.iconMedium * 0.75, weight: .medium))
                            .foregroundStyle(action.tintColor)
                            .frame(width: AppSizes.minTouchTarget, height: AppSizes.minTouchTarget)
                            .background(action.tintColor.opacity(0.14))
                            .clipShape(Circle())

                        Text(action.title)
                            .font(AppTypography.caption)
                            .foregroundStyle(AppTheme.textSecondary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.appPressScale)
                .accessibilityLabel(action.title)
            }
        }
    }

    // MARK: - Stat row

    private var statRow: some View {
        HStack(spacing: AppSpacing.sm) {
            FuelTrendCard(
                value: viewModel.fuelConsumptionText,
                changePercent: viewModel.fuelConsumptionChangePercent,
                history: viewModel.fuelHistory
            ) {
                appState.selectedTab = .analytics
            }

            ExpenseBreakdownCard(
                value: viewModel.monthlyExpensesText,
                changePercent: viewModel.monthlyExpensesChangePercent,
                breakdown: viewModel.expenseBreakdown
            ) {
                appState.selectedTab = .analytics
            }
        }
    }

    // MARK: - Next service

    private func nextServiceBanner(_ item: MaintenanceRecord) -> some View {
        let tone = item.status.tagTone
        let remaining = viewModel.nextServiceRemainingKm
        let mileageLine = remaining > 0
            ? "\(remaining.formattedMileage()) kaldı"
            : "\(abs(remaining).formattedMileage()) geçti"

        return Button {
            appState.selectedTab = .maintenance
        } label: {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: item.category.systemImage)
                    .font(.system(size: AppSizes.iconMedium))
                    .foregroundStyle(tone.foreground)
                    .frame(width: AppSizes.avatarSize, height: AppSizes.avatarSize)
                    .background(tone.background)
                    .clipShape(Circle())
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text("Sıradaki Bakım")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppTheme.textSecondary)
                        Text("· \(item.status.label)")
                            .font(AppTypography.captionEmphasized)
                            .foregroundStyle(tone.foreground)
                    }

                    Text(item.title)
                        .font(AppTypography.bodyEmphasized)
                        .foregroundStyle(AppTheme.textPrimary)

                    Text("\(mileageLine) · \(item.date.formattedDayMonthYear())")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                }

                Spacer(minLength: AppSpacing.xs)

                Image(systemName: "chevron.right")
                    .font(.system(size: AppSizes.iconXSmall, weight: .semibold))
                    .foregroundStyle(AppTheme.textTertiary)
            }
            .padding(AppSpacing.md)
            .background(tone.background)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
        }
        .buttonStyle(.appPressScale)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Sıradaki bakım: \(item.title), \(item.status.label), \(mileageLine)")
        .accessibilityHint("Bakım sekmesine git")
    }

    // MARK: - Recent activity

    private var recentActivity: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Son Hareketler")

            CardView {
                VStack(spacing: AppSpacing.sm) {
                    ForEach(Array(viewModel.recentActivity.enumerated()), id: \.element.id) { index, record in
                        ActivityRow(record: record)
                        if index < viewModel.recentActivity.count - 1 {
                            Divider()
                        }
                    }
                }
            }
        }
    }

    // MARK: - AI insight

    private var aiInsight: some View {
        Button {
            viewModel.isShowingInsightDetail = true
        } label: {
            HStack(alignment: .top, spacing: AppSpacing.sm) {
                Image(systemName: "sparkles")
                    .font(.system(size: AppSizes.iconSmall))
                    .foregroundStyle(AppTheme.primary)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.aiInsightMessage)
                        .font(AppTypography.subheadline)
                        .foregroundStyle(AppTheme.textPrimary)
                        .multilineTextAlignment(.leading)

                    Text("Detayları Gör")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppTheme.primary)
                }

                Spacer(minLength: 0)
            }
            .padding(AppSpacing.md)
            .background(AppTheme.primarySubtle)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
        }
        .buttonStyle(.appPressScale)
        .accessibilityLabel("AI Analizi: \(viewModel.aiInsightMessage)")
        .accessibilityHint("Detayları gör")
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
}

#Preview("Dark") {
    HomeView()
        .environmentObject(AppState())
        .preferredColorScheme(.dark)
}
