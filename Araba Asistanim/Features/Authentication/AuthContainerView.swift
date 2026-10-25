import SwiftUI

/// Owns the unauthenticated flow's navigation stack: Welcome is the root, with
/// the first-run onboarding (once) and sign in / sign up (`AuthView`, which
/// presents forgot password as a sheet) as push destinations. Kept separate from
/// AppRootView so the auth flow's own back-navigation is self-contained.
struct AuthContainerView: View {
    @State private var path = NavigationPath()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        NavigationStack(path: $path) {
            WelcomeView(
                onGetStarted: { path.append(hasSeenOnboarding ? AuthRoute.register : AuthRoute.onboarding) },
                onSignIn: { path.append(AuthRoute.login) }
            )
            .navigationDestination(for: AuthRoute.self) { route in
                switch route {
                case .onboarding:
                    OnboardingView {
                        hasSeenOnboarding = true
                        var next = NavigationPath()
                        next.append(AuthRoute.register)
                        path = next
                    }
                case .login:
                    AuthView(mode: .signIn)
                case .register:
                    AuthView(mode: .signUp)
                }
            }
        }
    }
}

#Preview {
    AuthContainerView()
        .environmentObject(AuthViewModel(repository: AuthRepository(
            service: MockAuthService(),
            secureStorage: InMemorySecureStorage()
        )))
}
