import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel

    @State private var email = ""
    @State private var emailError: String?
    @State private var isLoading = false
    @State private var isSuccess = false

    var body: some View {
        Group {
            if isSuccess {
                successState
            } else {
                form
            }
        }
        .padding(AppSpacing.md)
        .background(AppTheme.background)
        .navigationTitle("Şifremi Unuttum")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
    }

    private var form: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text("Şifreni sıfırla")
                        .font(AppTypography.largeTitle)
                        .foregroundStyle(AppTheme.textPrimary)

                    Text("Hesabına bağlı e-posta adresini gir, sana bir sıfırlama bağlantısı gönderelim.")
                        .font(AppTypography.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .padding(.top, AppSpacing.md)

                AppTextField(
                    title: "E-posta",
                    placeholder: "sen@ornek.com",
                    text: $email,
                    keyboardType: .emailAddress,
                    textContentType: .username,
                    errorMessage: emailError
                )
                .onChange(of: email) { emailError = nil }

                PrimaryButton(title: "Sıfırlama Bağlantısı Gönder", isLoading: isLoading) {
                    submit()
                }
            }
        }
    }

    private var successState: some View {
        VStack(spacing: AppSpacing.md) {
            Spacer()

            Image(systemName: "envelope.badge.fill")
                .font(.system(size: AppSizes.iconHero))
                .foregroundStyle(AppTheme.success)
                .accessibilityHidden(true)

            VStack(spacing: AppSpacing.xxs) {
                Text("Gelen kutunu kontrol et")
                    .font(AppTypography.title2)
                    .foregroundStyle(AppTheme.textPrimary)

                Text("Şifreni sıfırlamak için gerekli talimatlar \(email) adresine gönderildi.")
                    .font(AppTypography.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, AppSpacing.lg)
    }

    private func submit() {
        emailError = email.isValidEmail ? nil : "Geçerli bir e-posta adresi gir."
        guard emailError == nil else { return }

        isLoading = true
        Task {
            do {
                try await authViewModel.requestPasswordReset(email: email)
                isLoading = false
                withAnimation(AppAnimation.standard) {
                    isSuccess = true
                }
            } catch {
                isLoading = false
                emailError = AuthError.unknown.errorDescription
            }
        }
    }
}

#Preview {
    NavigationStack {
        ForgotPasswordView()
    }
    .environmentObject(AuthViewModel(repository: AuthRepository(
        service: MockAuthService(),
        secureStorage: InMemorySecureStorage()
    )))
}
