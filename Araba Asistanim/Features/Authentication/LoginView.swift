import SwiftUI

struct LoginView: View {
    let onForgotPassword: () -> Void
    let onCreateAccount: () -> Void

    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var emailError: String?
    @State private var passwordError: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text("Welcome back")
                        .font(AppTypography.largeTitle)
                        .foregroundStyle(AppTheme.textPrimary)

                    Text("Sign in to continue tracking your vehicle.")
                        .font(AppTypography.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .padding(.top, AppSpacing.md)

                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    AppTextField(
                        title: "Email",
                        placeholder: "you@example.com",
                        text: $email,
                        keyboardType: .emailAddress,
                        textContentType: .username,
                        errorMessage: emailError
                    )
                    .onChange(of: email) { emailError = nil; authViewModel.clearError() }

                    AppTextField(
                        title: "Password",
                        placeholder: "Password",
                        text: $password,
                        isSecure: true,
                        textContentType: .password,
                        errorMessage: passwordError
                    )
                    .onChange(of: password) { passwordError = nil; authViewModel.clearError() }

                    Button("Forgot Password?", action: onForgotPassword)
                        .font(AppTypography.subheadline)
                        .foregroundStyle(AppTheme.primary)
                }

                if let errorMessage = authViewModel.errorMessage {
                    ErrorView(message: errorMessage)
                }

                VStack(spacing: AppSpacing.sm) {
                    PrimaryButton(title: "Sign In", isLoading: authViewModel.isAuthenticating) {
                        submit()
                    }

                    SecondaryButton(title: "Create Account", action: onCreateAccount)
                }
            }
            .padding(AppSpacing.md)
        }
        .background(AppTheme.background)
        .navigationTitle("Sign In")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
    }

    private func submit() {
        authViewModel.clearError()
        emailError = email.isValidEmail ? nil : "Enter a valid email address."
        passwordError = password.isEmpty ? "Enter your password." : nil

        guard emailError == nil, passwordError == nil else { return }

        Task {
            await authViewModel.signIn(email: email, password: password)
        }
    }
}

#Preview {
    NavigationStack {
        LoginView(onForgotPassword: {}, onCreateAccount: {})
    }
    .environmentObject(AuthViewModel(repository: AuthRepository(
        service: MockAuthService(),
        secureStorage: InMemorySecureStorage()
    )))
}
