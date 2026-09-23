import SwiftUI

/// Owns the unauthenticated flow's navigation stack: Welcome is the root, with
/// Login/Register/ForgotPassword as push destinations. Kept separate from
/// AppRootView so the auth flow's own back-navigation is self-contained.
struct AuthContainerView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            WelcomeView(
                onGetStarted: { path.append(AuthRoute.register) },
                onSignIn: { path.append(AuthRoute.login) }
            )
            .navigationDestination(for: AuthRoute.self) { route in
                switch route {
                case .login:
                    LoginView(
                        onForgotPassword: { path.append(AuthRoute.forgotPassword) },
                        onCreateAccount: { path.append(AuthRoute.register) }
                    )
                case .register:
                    RegisterView()
                case .forgotPassword:
                    ForgotPasswordView()
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
