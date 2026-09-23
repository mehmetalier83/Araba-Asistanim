import SwiftUI

/// The true top-level view: gates the entire app on session state. Everything
/// authenticated (MainTabView and below) is unreachable once `signOut()` runs,
/// since this switch removes it from the view hierarchy entirely rather than
/// merely hiding it behind a sheet or leaving it on the navigation stack.
struct AppRootView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel

    var body: some View {
        Group {
            if authViewModel.currentUser != nil {
                MainTabView()
            } else {
                AuthContainerView()
            }
        }
        .animation(
            .respectingReduceMotion(AppAnimation.standard),
            value: authViewModel.currentUser
        )
    }
}

#Preview {
    AppRootView()
        .environmentObject(AppState())
        .environmentObject(AuthViewModel(repository: AuthRepository(
            service: MockAuthService(),
            secureStorage: InMemorySecureStorage()
        )))
}
