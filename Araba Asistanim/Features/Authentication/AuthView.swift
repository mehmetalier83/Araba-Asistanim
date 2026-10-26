import SwiftUI

/// Sign in and sign up on one screen, on the same dark brand canvas as
/// onboarding. A pill switch flips between the two modes; the mascot shuts its
/// eyes while a password is typed and shakes when something goes wrong.
/// Forgot password opens as a sheet. All auth calls go through `AuthViewModel`.
struct AuthView: View {
    enum Mode: Hashable {
        case signIn, signUp
    }

    @State var mode: Mode

    @EnvironmentObject private var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Namespace private var modeSwitch
    @FocusState private var focus: AuthField?

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var emailError: String?
    @State private var passwordError: String?
    @State private var confirmPasswordError: String?
    @State private var loadingProvider: AuthSocialButton.Provider?
    @State private var shakeCount = 0
    @State private var isShowingForgotPassword = false

    private var isSignUp: Bool { mode == .signUp }
    private var isTypingPassword: Bool { focus == .password || focus == .confirmPassword }
    private var isSubmitting: Bool { loadingProvider == nil && authViewModel.isAuthenticating }

    var body: some View {
        ZStack {
            BrandGlowBackground()

            FormScrollView {
                VStack(spacing: AppSpacing.lg) {
                    header
                    card
                    if isSignUp {
                        terms
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.bottom, AppSpacing.xl)
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollIndicators(.hidden)
        }
        .safeAreaInset(edge: .top) { topBar }
        .environment(\.colorScheme, .dark)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $isShowingForgotPassword) {
            ForgotPasswordSheet(initialEmail: email)
        }
        .onChange(of: authViewModel.errorMessage) { _, message in
            guard message != nil else { return }
            shakeCount += 1
            HapticFeedback.error()
        }
        .onChange(of: mode) {
            clearErrors()
        }
    }

    // MARK: - Header

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.85))
                    .frame(width: AppSizes.minTouchTarget, height: AppSizes.minTouchTarget)
                    .background(.white.opacity(0.08), in: Circle())
            }
            .accessibilityLabel("Geri")
            Spacer()
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.bottom, AppSpacing.xs)
        // Fades scrolled content out under the back button and status bar.
        .background {
            LinearGradient(
                stops: [
                    .init(color: Color(hex: 0x241D5E), location: 0),
                    .init(color: Color(hex: 0x241D5E).opacity(0.92), location: 0.7),
                    .init(color: Color(hex: 0x241D5E).opacity(0), location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .padding(.bottom, -AppSpacing.lg)
            .ignoresSafeArea(edges: .top)
        }
        .environment(\.colorScheme, .dark)
    }

    private var header: some View {
        VStack(spacing: AppSpacing.sm) {
            CarMascot(eyesClosed: isTypingPassword)
                .frame(width: 96, height: 96)
                .shake(trigger: reduceMotion ? 0 : shakeCount)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isTypingPassword)

            VStack(spacing: AppSpacing.xxs) {
                Text(isSignUp ? "Hesabını oluştur" : "Tekrar hoş geldin")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                    .contentTransition(.opacity)
                Text(isSignUp ? "Aracını dakikalar içinde takip etmeye başla." : "Aracın seni bekliyor. Kaldığın yerden devam et.")
                    .font(AppTypography.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .contentTransition(.opacity)
            }
        }
        .padding(.top, AppSpacing.xs)
    }

    // MARK: - Card

    private var card: some View {
        VStack(spacing: AppSpacing.md) {
            modePicker

            VStack(spacing: AppSpacing.sm) {
                AuthTextField(
                    label: "E-posta",
                    systemImage: "envelope.fill",
                    text: $email,
                    field: .email,
                    focus: $focus,
                    keyboardType: .emailAddress,
                    textContentType: .username,
                    errorMessage: emailError
                ) { focus = .password }
                .onChange(of: email) { emailError = nil; authViewModel.clearError() }

                AuthTextField(
                    label: "Şifre",
                    systemImage: "lock.fill",
                    text: $password,
                    field: .password,
                    focus: $focus,
                    isSecure: true,
                    textContentType: isSignUp ? .newPassword : .password,
                    submitLabel: isSignUp ? .next : .go,
                    errorMessage: passwordError
                ) {
                    if isSignUp { focus = .confirmPassword } else { submit() }
                }
                .onChange(of: password) { passwordError = nil; authViewModel.clearError() }

                if isSignUp {
                    AuthTextField(
                        label: "Şifreyi onayla",
                        systemImage: "lock.rotation",
                        text: $confirmPassword,
                        field: .confirmPassword,
                        focus: $focus,
                        isSecure: true,
                        textContentType: .newPassword,
                        submitLabel: .join,
                        errorMessage: confirmPasswordError
                    ) { submit() }
                    .onChange(of: confirmPassword) { confirmPasswordError = nil }
                    .transition(.opacity.combined(with: .move(edge: .top)))

                    PasswordStrengthView(password: password)
                        .padding(.top, AppSpacing.xxs)
                        .transition(.opacity)
                } else {
                    HStack {
                        Spacer()
                        Button("Şifremi unuttum") { isShowingForgotPassword = true }
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color(hex: 0xB9B3FF))
                    }
                    .transition(.opacity)
                }
            }

            if let message = authViewModel.errorMessage {
                Label(message, systemImage: "exclamationmark.triangle.fill")
                    .font(.footnote)
                    .foregroundStyle(Color(hex: 0xFF8A8A))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(AppSpacing.sm)
                    .background(Color(hex: 0xFF6B6B).opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }

            AuthPrimaryButton(title: isSignUp ? "Hesap Oluştur" : "Giriş Yap", isLoading: isSubmitting) {
                submit()
            }
            .disabled(loadingProvider != nil)

            AuthDivider()

            VStack(spacing: AppSpacing.sm) {
                if AppFeatures.appleSignInEnabled {
                    AuthSocialButton(provider: .apple, isLoading: loadingProvider == .apple) { signIn(with: .apple) }
                }
                AuthSocialButton(provider: .google, isLoading: loadingProvider == .google) { signIn(with: .google) }
            }
            .disabled(authViewModel.isAuthenticating)
        }
        .padding(AppSpacing.lg)
        .authGlassCard()
        .animation(reduceMotion ? nil : .spring(response: 0.45, dampingFraction: 0.85), value: mode)
        .animation(.easeOut(duration: 0.2), value: authViewModel.errorMessage)
    }

    private var modePicker: some View {
        HStack(spacing: 0) {
            ForEach([Mode.signIn, Mode.signUp], id: \.self) { item in
                Button {
                    withAnimation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.82)) { mode = item }
                } label: {
                    Text(item == .signIn ? "Giriş Yap" : "Kayıt Ol")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(mode == item ? .white : .white.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background {
                            if mode == item {
                                Capsule()
                                    .fill(LinearGradient.mascot(startPoint: .leading, endPoint: .trailing))
                                    .matchedGeometryEffect(id: "mode", in: modeSwitch)
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(mode == item ? [.isButton, .isSelected] : .isButton)
            }
        }
        .padding(4)
        .background(.white.opacity(0.08), in: Capsule())
        .sensoryFeedback(.selection, trigger: mode)
    }

    private var terms: some View {
        Text("Hesap oluşturarak **Kullanım Koşulları**'nı ve **Gizlilik Politikası**'nı kabul etmiş olursun.")
            .font(.caption)
            .foregroundStyle(.white.opacity(0.5))
            .multilineTextAlignment(.center)
            .padding(.horizontal, AppSpacing.md)
            .transition(.opacity)
    }

    // MARK: - Actions

    private func clearErrors() {
        emailError = nil
        passwordError = nil
        confirmPasswordError = nil
        authViewModel.clearError()
    }

    private func submit() {
        clearErrors()
        emailError = email.isValidEmail ? nil : "Geçerli bir e-posta adresi gir."

        if isSignUp {
            if !PasswordRequirement.allSatisfied(by: password) {
                passwordError = "Şifren aşağıdaki kuralların hepsini karşılamalı."
            }
            confirmPasswordError = confirmPassword == password ? nil : "Şifreler eşleşmiyor."
        } else {
            passwordError = password.isEmpty ? "Şifreni gir." : nil
        }

        guard emailError == nil, passwordError == nil, confirmPasswordError == nil else {
            shakeCount += 1
            HapticFeedback.error()
            return
        }

        focus = nil
        Task {
            if isSignUp {
                await authViewModel.signUp(email: email, password: password)
            } else {
                await authViewModel.signIn(email: email, password: password)
            }
            if authViewModel.currentUser != nil { HapticFeedback.success() }
        }
    }

    private func signIn(with provider: AuthSocialButton.Provider) {
        clearErrors()
        loadingProvider = provider
        Task {
            switch provider {
            case .google: await authViewModel.signInWithGoogle()
            case .apple: await authViewModel.signInWithApple()
            }
            loadingProvider = nil
            if authViewModel.currentUser != nil { HapticFeedback.success() }
        }
    }
}

// MARK: - Forgot password

/// Asks for the account email and sends a reset link; then confirms with an
/// animated envelope.
struct ForgotPasswordSheet: View {
    var initialEmail = ""

    @EnvironmentObject private var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focus: AuthField?

    @State private var email = ""
    @State private var emailError: String?
    @State private var isLoading = false
    @State private var isSent = false

    var body: some View {
        ZStack {
            BrandGlowBackground(accent: AppColors.mascotIndigo)

            VStack(spacing: AppSpacing.lg) {
                Color.clear.frame(height: AppSpacing.sm)

                if isSent {
                    sentState
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                } else {
                    form
                        .transition(.opacity)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, AppSpacing.lg)
        }
        .environment(\.colorScheme, .dark)
        .presentationDetents([.medium, .large])
        .presentationCornerRadius(32)
        .presentationDragIndicator(.visible)
        .onAppear { email = initialEmail }
    }

    private var form: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Image(systemName: "key.fill")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(LinearGradient.mascot(), in: Circle())

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text("Şifreni mi unuttun?")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                Text("Hesabına bağlı e-posta adresini gir, sana bir sıfırlama bağlantısı gönderelim.")
                    .font(AppTypography.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }

            AuthTextField(
                label: "E-posta",
                systemImage: "envelope.fill",
                text: $email,
                field: .email,
                focus: $focus,
                keyboardType: .emailAddress,
                textContentType: .username,
                submitLabel: .send,
                errorMessage: emailError
            ) { submit() }
            .onChange(of: email) { emailError = nil }

            AuthPrimaryButton(title: "Bağlantı Gönder", isLoading: isLoading) { submit() }
        }
    }

    private var sentState: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "envelope.open.fill")
                .font(.system(size: 54))
                .foregroundStyle(LinearGradient.mascot())
                .symbolEffect(.bounce, value: isSent)
                .padding(.top, AppSpacing.lg)

            Text("E-posta gönderildi")
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundStyle(.white)

            Text("Şifreni sıfırlama bağlantısını \(email) adresine gönderdik. Gelen kutunu (ve gereksiz klasörünü) kontrol et.")
                .font(AppTypography.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)

            AuthPrimaryButton(title: "Tamam") { dismiss() }
                .padding(.top, AppSpacing.sm)
        }
        .sensoryFeedback(.success, trigger: isSent)
    }

    private func submit() {
        emailError = email.isValidEmail ? nil : "Geçerli bir e-posta adresi gir."
        guard emailError == nil else { return }

        focus = nil
        isLoading = true
        Task {
            do {
                try await authViewModel.requestPasswordReset(email: email)
                isLoading = false
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { isSent = true }
            } catch {
                isLoading = false
                emailError = AuthError.unknown.errorDescription
            }
        }
    }
}

#Preview {
    NavigationStack {
        AuthView(mode: .signIn)
    }
    .environmentObject(AuthViewModel(repository: AuthRepository(
        service: MockAuthService(),
        secureStorage: InMemorySecureStorage()
    )))
}
