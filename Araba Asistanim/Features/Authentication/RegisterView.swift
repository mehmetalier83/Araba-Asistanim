import SwiftUI

/// Registration asks for nothing but email and password — no name, no vehicle
/// info, nothing else. A display name is derived from the email behind the
/// scenes (see `MockAuthService`); anything more can be filled in later from
/// Settings. Google/Apple skip the form entirely.
struct RegisterView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    @State private var emailError: String?
    @State private var confirmPasswordError: String?
    @State private var hasTouchedPassword = false
    @State private var loadingProvider: SocialSignInButton.Provider?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text("Hesabını oluştur")
                        .font(AppTypography.largeTitle)
                        .foregroundStyle(AppTheme.textPrimary)

                    Text("Aracını dakikalar içinde takip etmeye başla.")
                        .font(AppTypography.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .padding(.top, AppSpacing.md)

                VStack(spacing: AppSpacing.sm) {
                    SocialSignInButton(provider: .apple, isLoading: loadingProvider == .apple) {
                        signIn(with: .apple)
                    }
                    SocialSignInButton(provider: .google, isLoading: loadingProvider == .google) {
                        signIn(with: .google)
                    }
                }
                .disabled(authViewModel.isAuthenticating)

                OrDivider()

                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    AppTextField(
                        title: "E-posta",
                        placeholder: "sen@ornek.com",
                        text: $email,
                        keyboardType: .emailAddress,
                        textContentType: .username,
                        errorMessage: emailError
                    )
                    .onChange(of: email) { emailError = nil; authViewModel.clearError() }

                    AppTextField(
                        title: "Şifre",
                        placeholder: "Şifre",
                        text: $password,
                        isSecure: true,
                        textContentType: .newPassword
                    )
                    .onChange(of: password) { hasTouchedPassword = true; authViewModel.clearError() }

                    if hasTouchedPassword {
                        passwordRequirements
                    }

                    AppTextField(
                        title: "Şifreyi Onayla",
                        placeholder: "Şifre",
                        text: $confirmPassword,
                        isSecure: true,
                        textContentType: .newPassword,
                        errorMessage: confirmPasswordError
                    )
                    .onChange(of: confirmPassword) { confirmPasswordError = nil }
                }

                if let errorMessage = authViewModel.errorMessage {
                    ErrorView(message: errorMessage)
                }

                PrimaryButton(title: "Hesap Oluştur", isLoading: loadingProvider == nil && authViewModel.isAuthenticating) {
                    submit()
                }
                .disabled(loadingProvider != nil)
            }
            .padding(AppSpacing.md)
        }
        .background(AppTheme.background)
        .navigationTitle("Hesap Oluştur")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
    }

    private var passwordRequirements: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Şifre gereksinimleri")
                .font(AppTypography.footnote)
                .foregroundStyle(AppTheme.textSecondary)

            ForEach(PasswordRequirement.allCases) { requirement in
                let satisfied = requirement.isSatisfied(by: password)
                HStack(spacing: AppSpacing.xxs) {
                    Image(systemName: satisfied ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(satisfied ? AppTheme.success : AppTheme.textTertiary)
                        .font(.system(size: AppSizes.iconXSmall))
                    Text(requirement.description)
                        .font(AppTypography.footnote)
                        .foregroundStyle(satisfied ? AppTheme.textPrimary : AppTheme.textSecondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(requirement.description): \(satisfied ? "karşılandı" : "karşılanmadı")")
            }
        }
        .padding(.top, -AppSpacing.xs)
        .animation(AppAnimation.fast, value: password)
    }

    private func submit() {
        authViewModel.clearError()
        emailError = email.isValidEmail ? nil : "Geçerli bir e-posta adresi gir."
        confirmPasswordError = confirmPassword == password ? nil : "Şifreler eşleşmiyor."
        hasTouchedPassword = true

        guard emailError == nil, confirmPasswordError == nil,
              PasswordRequirement.allSatisfied(by: password) else { return }

        Task {
            await authViewModel.signUp(email: email, password: password)
        }
    }

    private func signIn(with provider: SocialSignInButton.Provider) {
        authViewModel.clearError()
        loadingProvider = provider
        Task {
            switch provider {
            case .google:
                await authViewModel.signInWithGoogle()
            case .apple:
                await authViewModel.signInWithApple()
            }
            loadingProvider = nil
        }
    }
}

#Preview {
    NavigationStack {
        RegisterView()
    }
    .environmentObject(AuthViewModel(repository: AuthRepository(
        service: MockAuthService(),
        secureStorage: InMemorySecureStorage()
    )))
}
