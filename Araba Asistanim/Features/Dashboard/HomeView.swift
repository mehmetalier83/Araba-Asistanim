import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var store: GarageStore
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var path = NavigationPath()
    @State private var isShowingNotifications = false
    @State private var plan = OnboardingPreferences.isPlanCardDismissed ? nil : OnboardingPreferences.load()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var vehicle: Vehicle? { store.selectedVehicle }
    private var insights: GarageInsights? { vehicle.map { GarageInsights(store: store, vehicle: $0) } }
    private var recentActivityRecords: [ExpenseRecord] { Array(insights?.spending.prefix(3) ?? []) }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    topBar
                    greeting

                    if let plan {
                        planCard(plan)
                    }

                    if let vehicle, let insights {
                        MaintenanceScoreCard(score: insights.maintenanceScore) {
                            appState.selectedTab = .maintenance
                        }

                        statusGrid(vehicle: vehicle, insights: insights)
                        aiInsights(insights)
                        actionRow

                        if !recentActivityRecords.isEmpty {
                            recentActivity
                        }
                    } else {
                        emptyGarageCard
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.bottom, AppSpacing.xl)
            }
            .appScreenBackground()
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case .settings:
                    SettingsView()
                case .vehicleDetail(let vehicle):
                    VehicleDetailView(vehicleID: vehicle.id)
                case .expenses(let vehicle):
                    ExpensesListView(vehicle: vehicle)
                }
            }
            .sheet(item: $viewModel.activeQuickAction) { action in
                if let vehicle {
                    switch action {
                    case .addExpense:
                        AddExpenseView(vehicle: vehicle) { store.addExpense($0) }
                    case .addFuel:
                        AddFuelView(vehicle: vehicle) { store.addFuel($0) }
                    case .addMaintenance:
                        AddMaintenanceView(vehicle: vehicle) { store.addMaintenance($0) }
                    }
                }
            }
            .sheet(isPresented: $viewModel.isShowingAddVehicle) {
                AddVehicleView { vehicle in
                    withAnimation(reduceMotion ? nil : AppAnimation.standard) {
                        store.addVehicle(vehicle)
                        store.selectedVehicleID = vehicle.id
                    }
                }
            }
            .sheet(isPresented: $viewModel.isShowingInsightDetail) {
                PlaceholderSheet(
                    systemImage: "sparkles",
                    title: "Araç Analizi",
                    message: insights?.detail ?? ""
                )
            }
            .sheet(isPresented: $isShowingNotifications) {
                NotificationsSheet(reminders: store.attentionReminders) {
                    appState.selectedTab = .maintenance
                }
            }
        }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack(spacing: AppSpacing.xs) {
            CarMascot(animates: false, glows: false)
                .padding(4)
                .frame(width: 32, height: 32)
                .background(LinearGradient.mascot(), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                .accessibilityHidden(true)

            Text(AppBrand.name)
                .font(AppTypography.headline)
                .foregroundStyle(AppTheme.textPrimary)

            Spacer()

            ZStack(alignment: .topTrailing) {
                IconButton(systemImage: "bell", accessibilityLabel: "Bildirimler") {
                    isShowingNotifications = true
                }
                if !store.attentionReminders.isEmpty {
                    Circle()
                        .fill(LinearGradient.mascot(startPoint: .leading, endPoint: .trailing))
                        .frame(width: 10, height: 10)
                        .overlay(Circle().stroke(AppTheme.cardBackground, lineWidth: 2))
                        .offset(x: -9, y: 9)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }
            .accessibilityValue(store.attentionReminders.isEmpty ? "" : "\(store.attentionReminders.count) uyarı")

            Button {
                path.append(HomeRoute.settings)
            } label: {
                Text(authViewModel.currentUser?.initials ?? "")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: AppSizes.minTouchTarget, height: AppSizes.minTouchTarget)
                    .background(LinearGradient.mascot(startPoint: .topLeading, endPoint: .bottomTrailing), in: Circle())
                    .overlay(Circle().stroke(AppTheme.cardBackground, lineWidth: 2))
            }
            .buttonStyle(.appPressScale)
            .accessibilityLabel("Profil ve Ayarlar")
        }
        .padding(.top, AppSpacing.xs)
    }

    // MARK: - Greeting

    private var greeting: some View {
        HStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(HomeViewModel.greeting())
                    .font(AppTypography.title3.weight(.regular))
                    .foregroundStyle(AppTheme.textPrimary)

                Text("\(authViewModel.currentUser?.firstName ?? "Hoş geldin") 👋")
                    .font(.system(.largeTitle, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(vehicle == nil ? "Başlamak için aracını ekle." : "İşte aracının genel durumu.")
                    .font(AppTypography.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
                    .padding(.top, AppSpacing.xxs)

                VehicleSwitcherMenu()
                    .padding(.top, AppSpacing.xxs)
            }

            Spacer(minLength: AppSpacing.sm)

            if let vehicle {
                Button {
                    path.append(HomeRoute.vehicleDetail(vehicle))
                } label: {
                    carGlyph
                }
                .buttonStyle(.appPressScale)
                .accessibilityLabel("\(vehicle.displayName) detayları")
            }
        }
    }

    /// The vehicle illustration: a large gradient car glyph over a soft halo.
    private var carGlyph: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [AppColors.mascotViolet.opacity(0.28), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)

            Image(systemName: "car.side.fill")
                .font(.system(size: 76))
                .foregroundStyle(LinearGradient.mascot(startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(color: AppColors.mascotIndigo.opacity(0.35), radius: 14, y: 8)
        }
        .frame(width: 140, height: 120)
    }

    // MARK: - Plan

    /// A one-time card echoing what the person chose during onboarding.
    private func planCard(_ plan: OnboardingPreferences) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Image(systemName: "sparkles")
                .font(.system(size: AppSizes.iconSmall, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(LinearGradient.mascot(), in: Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text("Planın hazır")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppTheme.textPrimary)

                if !plan.goals.isEmpty {
                    Text(plan.goals.map(\.title).joined(separator: " · "))
                        .font(AppTypography.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                }

                Text("Ayda ~\(plan.monthlyKm.formattedMileage()) ile yağ değişimi yaklaşık her \(plan.monthsPerOilChange) ayda bir.")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer(minLength: 0)

            Button {
                OnboardingPreferences.isPlanCardDismissed = true
                withAnimation(reduceMotion ? nil : AppAnimation.standard) { self.plan = nil }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: AppSizes.iconXSmall, weight: .semibold))
                    .foregroundStyle(AppTheme.textTertiary)
                    .frame(width: AppSizes.minTouchTarget, height: AppSizes.minTouchTarget)
            }
            .accessibilityLabel("Kapat")
        }
        .padding(.leading, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background(AppTheme.primarySubtle)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
    }

    // MARK: - Empty garage

    private var emptyGarageCard: some View {
        ZStack(alignment: .bottomLeading) {
            BrandHeroBackground()

            VStack(alignment: .leading, spacing: AppSpacing.md) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Henüz aracın yok")
                        .font(AppTypography.title2)
                        .foregroundStyle(.white)

                    Text("Bakım, yakıt ve giderlerini takip etmeye başlamak için ilk aracını ekle.")
                        .font(AppTypography.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                }

                Button {
                    viewModel.isShowingAddVehicle = true
                } label: {
                    HStack(spacing: 4) {
                        Text("Araç Ekle")
                        Image(systemName: "plus")
                    }
                    .font(AppTypography.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.mascotIndigo)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.xs)
                    .background(.white, in: Capsule())
                }
                .buttonStyle(.appPressScale)
            }
            .padding(AppSpacing.lg)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.hero, style: .continuous))
        .appShadow(AppShadow.primaryGlow)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Henüz aracın yok")
        .accessibilityHint("Araç eklemek için dokun")
    }

    // MARK: - Status grid

    private func statusGrid(vehicle: Vehicle, insights: GarageInsights) -> some View {
        let next = insights.nextReminder
        let nextSubtitle: String = {
            guard let next else { return "Planlı bakım yok" }
            guard next.tracksMileage else { return next.status.label }
            let remaining = insights.remainingKm(to: next)
            return remaining > 0 ? "\(remaining.formattedMileage()) kaldı" : "\(abs(remaining).formattedMileage()) geçti"
        }()

        return LazyVGrid(columns: [GridItem(.flexible(), spacing: AppSpacing.sm), GridItem(.flexible())], spacing: AppSpacing.sm) {
            StatusTile(
                systemImage: "calendar",
                tint: next.map { $0.status.tagTone.foreground } ?? AppTheme.categoryPurple,
                title: next?.title ?? "Sıradaki Bakım",
                subtitle: nextSubtitle
            ) {
                appState.selectedTab = .maintenance
            }

            StatusTile(
                systemImage: "gauge.with.dots.needle.67percent",
                tint: AppTheme.primary,
                title: "Kilometre",
                subtitle: vehicle.mileageKm.formattedMileage()
            ) {
                path.append(HomeRoute.vehicleDetail(vehicle))
            }

            StatusTile(
                systemImage: "fuelpump",
                tint: AppTheme.categoryTeal,
                title: "Ort. Tüketim",
                subtitle: insights.latestConsumption?.value.formattedFuelConsumption() ?? "Henüz veri yok"
            ) {
                appState.selectedTab = .analytics
            }

            StatusTile(
                systemImage: "turkishlirasign",
                tint: AppTheme.success,
                title: "Bu Ay Gider",
                subtitle: insights.thisMonthTotal.formattedCurrencyTL()
            ) {
                path.append(HomeRoute.expenses(vehicle))
            }
        }
    }

    // MARK: - AI insights

    private func aiInsights(_ insights: GarageInsights) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Son AI Önerileri", actionTitle: "Asistana Sor") {
                appState.selectedTab = .aiAssistant
            }

            Button {
                viewModel.isShowingInsightDetail = true
            } label: {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "sparkles")
                        .font(.system(size: AppSizes.iconSmall, weight: .semibold))
                        .foregroundStyle(AppColors.mascotViolet)
                        .frame(width: AppSizes.avatarSize, height: AppSizes.avatarSize)
                        .background(AppColors.mascotViolet.opacity(0.12), in: Circle())
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(insights.headline)
                            .font(AppTypography.subheadline.weight(.medium))
                            .foregroundStyle(AppTheme.textPrimary)
                            .multilineTextAlignment(.leading)

                        Text("Detayları gör")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppTheme.textSecondary)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.system(size: AppSizes.iconXSmall, weight: .semibold))
                        .foregroundStyle(AppTheme.textTertiary)
                }
                .padding(AppSpacing.md)
                .appCard()
            }
            .buttonStyle(.appPressScale)
            .accessibilityLabel("AI Analizi: \(insights.headline)")
            .accessibilityHint("Detayları gör")
        }
    }

    // MARK: - Actions

    /// The add-record menu as a wide gradient pill, with a round AI button next to it.
    private var actionRow: some View {
        HStack(spacing: AppSpacing.sm) {
            Menu {
                ForEach(QuickActionType.allCases) { action in
                    Button {
                        viewModel.selectQuickAction(action)
                    } label: {
                        Label(action.title, systemImage: action.systemImage)
                    }
                }
            } label: {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "plus.circle.fill")
                    Text("Kayıt Ekle")
                }
                .font(AppTypography.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(LinearGradient.mascot(startPoint: .leading, endPoint: .trailing), in: Capsule())
                .appShadow(AppShadow.primaryGlow)
            }
            .accessibilityLabel("Kayıt Ekle")
            .accessibilityHint("Yakıt, gider veya bakım ekle")

            Button {
                appState.selectedTab = .aiAssistant
            } label: {
                Image(systemName: "sparkles")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(LinearGradient.mascot(startPoint: .topLeading, endPoint: .bottomTrailing), in: Circle())
                    .appShadow(AppShadow.primaryGlow)
            }
            .buttonStyle(.appPressScale)
            .accessibilityLabel("AI Asistan")
        }
    }

    // MARK: - Recent activity

    private var recentActivity: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Son Hareketler")

            CardView {
                VStack(spacing: AppSpacing.sm) {
                    ForEach(Array(recentActivityRecords.enumerated()), id: \.element.id) { index, record in
                        ActivityRow(record: record)
                        if index < recentActivityRecords.count - 1 {
                            Divider()
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Maintenance score card

/// The large score card: the number on the left, a thick gradient ring on the
/// right. The score comes from `GarageInsights.maintenanceScore`; without any
/// maintenance logged the card explains how to get one instead of inventing it.
private struct MaintenanceScoreCard: View {
    let score: Int?
    let action: () -> Void

    @State private var animatedProgress: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var status: (label: String, color: Color) {
        switch score ?? 0 {
        case 90...: return ("Mükemmel", AppTheme.success)
        case 70..<90: return ("İyi", AppTheme.success)
        case 50..<70: return ("Dikkat", AppTheme.warning)
        default: return ("Bakım gerekli", AppTheme.error)
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.md) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Bakım Sağlık Skoru")
                        .font(AppTypography.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)

                    if let score {
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("\(score)")
                                .font(.system(size: 56, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.textPrimary)
                                .contentTransition(.numericText())
                            Text("%")
                                .font(.system(.title2, design: .rounded, weight: .semibold))
                                .foregroundStyle(AppTheme.textPrimary)
                        }

                        Text(status.label)
                            .font(AppTypography.subheadline.weight(.semibold))
                            .foregroundStyle(status.color)
                    } else {
                        Text("Henüz yok")
                            .font(.system(.title, design: .rounded, weight: .bold))
                            .foregroundStyle(AppTheme.textPrimary)

                        Text("Bakım kaydı ekledikçe hesaplanır.")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }

                Spacer(minLength: 0)

                ring
            }
            .padding(AppSpacing.lg)
            .appCard(cornerRadius: AppCornerRadius.hero)
        }
        .buttonStyle(.appPressScale)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(score.map { "Bakım sağlık skoru yüzde \($0), \(status.label)" } ?? "Bakım sağlık skoru henüz yok")
        .accessibilityHint("Bakım sekmesine git")
        .onAppear { animate(to: score) }
        .onChange(of: score) { _, newValue in animate(to: newValue) }
    }

    private var ring: some View {
        ZStack {
            Circle()
                .stroke(AppTheme.primarySubtle, lineWidth: 14)

            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        colors: [AppColors.mascotIndigo, AppColors.mascotViolet, AppColors.mascotIndigo],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            Image(systemName: "heart.fill")
                .font(.system(size: 20))
                .foregroundStyle(LinearGradient.mascot(startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 52, height: 52)
                .background(AppTheme.cardBackground, in: Circle())
                .shadow(color: AppShadow.card.color, radius: 8, y: 3)
        }
        .frame(width: 116, height: 116)
    }

    private func animate(to score: Int?) {
        let target = Double(score ?? 0) / 100
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.9)) {
            animatedProgress = target
        }
    }
}

// MARK: - Status tile

/// A small card in Home's 2×2 grid: a pastel icon badge, a title and a value.
private struct StatusTile: View {
    let systemImage: String
    let tint: Color
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: systemImage)
                    .font(.system(size: AppSizes.iconSmall, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 38, height: 38)
                    .background(tint.opacity(0.12), in: Circle())
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppTypography.subheadline.weight(.medium))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    Text(subtitle)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineLimit(2)
                }

                Spacer(minLength: 0)
            }
            .padding(AppSpacing.sm)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .frame(minHeight: 68)
            .appCard()
        }
        .buttonStyle(.appPressScale)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
        .environmentObject(GarageStore.preview)
        .environmentObject(AuthViewModel(repository: AuthRepository(
            service: MockAuthService(),
            secureStorage: InMemorySecureStorage()
        )))
}

#Preview("Dark") {
    HomeView()
        .environmentObject(AppState())
        .environmentObject(GarageStore.preview)
        .environmentObject(AuthViewModel(repository: AuthRepository(
            service: MockAuthService(),
            secureStorage: InMemorySecureStorage()
        )))
        .preferredColorScheme(.dark)
}
