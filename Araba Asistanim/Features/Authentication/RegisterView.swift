import SwiftUI

struct RegisterView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    @State private var firstNameError: String?
    @State private var lastNameError: String?
    @State private var emailError: String?
    @State private var confirmPasswordError: String?
    @State private var hasTouchedPassword = false

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

                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    HStack(spacing: AppSpacing.sm) {
                        AppTextField(title: "Ad", placeholder: "Ayşe", text: $firstName, textContentType: .givenName, errorMessage: firstNameError)
                            .onChange(of: firstName) { firstNameError = nil }

                        AppTextField(title: "Soyad", placeholder: "Yılmaz", text: $lastName, textContentType: .familyName, errorMessage: lastNameError)
                            .onChange(of: lastName) { lastNameError = nil }
                    }

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

                PrimaryButton(title: "Hesap Oluştur", isLoading: authViewModel.isAuthenticating) {
                    submit()
                }
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
        firstNameError = firstName.trimmingCharacters(in: .whitespaces).isEmpty ? "Adını gir." : nil
        lastNameError = lastName.trimmingCharacters(in: .whitespaces).isEmpty ? "Soyadını gir." : nil
        emailError = email.isValidEmail ? nil : "Geçerli bir e-posta adresi gir."
        confirmPasswordError = confirmPassword == password ? nil : "Şifreler eşleşmiyor."
        hasTouchedPassword = true

        guard firstNameError == nil, lastNameError == nil, emailError == nil,
              confirmPasswordError == nil, PasswordRequirement.allSatisfied(by: password) else { return }

        Task {
            await authViewModel.signUp(firstName: firstName, lastName: lastName, email: email, password: password)
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
