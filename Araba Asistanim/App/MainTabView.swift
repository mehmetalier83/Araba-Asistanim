import SwiftUI

/// The main tab bar shell, shown once the user is authenticated. Each tab owns
/// its own NavigationStack, so navigation state (e.g. a pushed detail screen)
/// is preserved independently per tab when switching between them.
struct MainTabView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            ForEach(AppTab.allCases) { tab in
                tabContent(for: tab)
                    .tabItem {
                        Label(tab.title, systemImage: tab.systemImage)
                    }
                    .tag(tab)
            }
        }
    }

    @ViewBuilder
    private func tabContent(for tab: AppTab) -> some View {
        switch tab {
        case .home:
            HomeView()
        case .vehicles:
            VehicleListView()
        case .maintenance:
            MaintenanceView()
        case .analytics:
            AnalyticsView()
        case .aiAssistant:
            AIAssistantView()
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppState())
}
