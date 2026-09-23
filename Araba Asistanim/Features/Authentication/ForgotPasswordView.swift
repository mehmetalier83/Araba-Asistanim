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
        .navigationTitle("Forgot Password")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
    }

    private var form: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text("Reset your password")
                        .font(AppTypography.largeTitle)
                        .foregroundStyle(AppTheme.textPrimary)

                    Text("Enter the email associated with your account and we'll send you a reset link.")
                        .font(AppTypography.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .padding(.top, AppSpacing.md)

                AppTextField(
                    title: "Email",
                    placeholder: "you@example.com",
                    text: $email,
                    keyboardType: .emailAddress,
                    textContentType: .username,
                    errorMessage: emailError
                )
                .onChange(of: email) { emailError = nil }

                PrimaryButton(title: "Send Reset Link", isLoading: isLoading) {
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
                Text("Check your inbox")
                    .font(AppTypography.title2)
                    .foregroundStyle(AppTheme.textPrimary)

                Text("Instructions to reset your password have been sent to \(email).")
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
        emailError = email.isValidEmail ? nil : "Enter a valid email address."
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
