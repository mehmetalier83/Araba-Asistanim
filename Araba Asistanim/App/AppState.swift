import Combine
import SwiftUI

/// Root observable state shared across the app via the environment.
/// Intentionally minimal in this phase — no session, auth, or data state yet.
/// Later phases will add published properties here (e.g. current user,
/// selected vehicle) as those features are built.
@MainActor
final class AppState: ObservableObject {
    @Published var selectedTab: AppTab = .home

    init() {}
}
