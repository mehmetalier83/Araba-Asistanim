import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject private var appState: AppState
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    header

                    VehicleHeroCard(vehicle: viewModel.vehicle) {
                        path.append(HomeRoute.vehicleDetail(viewModel.vehicle))
                    }

                    quickActions

                    VehicleHealthCard(rows: viewModel.healthRows)

                    if let item = viewModel.nextMaintenanceItem {
                        upcomingMaintenance(item)
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
                    title: "Fuel Consumption Insight",
                    message: viewModel.aiInsightDetail
                )
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Good morning")
                    .font(AppTypography.title)
                    .foregroundStyle(AppTheme.textPrimary)

                Text("Here's how your car is doing.")
                    .font(AppTypography.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            IconButton(systemImage: "gearshape.fill", accessibilityLabel: "Settings") {
                path.append(HomeRoute.settings)
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
                            .foregroundStyle(AppTheme.primary)
                            .frame(width: AppSizes.minTouchTarget, height: AppSizes.minTouchTarget)
                            .background(AppTheme.primarySubtle)
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

    // MARK: - Upcoming maintenance

    private func upcomingMaintenance(_ item: MaintenanceRecord) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Upcoming Maintenance", actionTitle: "View All") {
                appState.selectedTab = .maintenance
            }

            Button {
                appState.selectedTab = .maintenance
            } label: {
                CardView {
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: item.category.systemImage)
                            .font(.system(size: AppSizes.iconSmall))
                            .foregroundStyle(item.status.tagTone.foreground)
                            .frame(width: AppSizes.iconLarge, height: AppSizes.iconLarge)
                            .background(item.status.tagTone.background)
                            .clipShape(Circle())
                            .accessibilityHidden(true)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(AppTypography.bodyEmphasized)
                                .foregroundStyle(AppTheme.textPrimary)

                            Text(item.date.formattedDayMonthYear())
                                .font(AppTypography.caption)
                                .foregroundStyle(AppTheme.textSecondary)
                        }

                        Spacer()

                        TagView(text: item.status.label, tone: item.status.tagTone)
                    }
                }
            }
            .buttonStyle(.appPressScale)
        }
    }

    // MARK: - Recent activity

    private var recentActivity: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Recent Activity")

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

                    Text("View Details")
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
        .accessibilityLabel("AI Insight: \(viewModel.aiInsightMessage)")
        .accessibilityHint("View details")
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
