import SwiftUI

/// A labeled text field styled for forms (auth today, other data-entry forms
/// later). Shows a subtle accent border only while focused — quiet by default,
/// clear when active — and an inline error message when `errorMessage` is set.
struct AppTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var errorMessage: String? = nil

    @FocusState private var isFocused: Bool
    @State private var isSecureTextVisible = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text(title)
                .font(AppTypography.footnote)
                .foregroundStyle(AppTheme.textSecondary)

            HStack(spacing: AppSpacing.xs) {
                Group {
                    if isSecure && !isSecureTextVisible {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .focused($isFocused)
                .keyboardType(keyboardType)
                .textContentType(textContentType)
                .autocorrectionDisabled(isSecure || keyboardType == .emailAddress)
                .textInputAutocapitalization(isSecure || keyboardType == .emailAddress ? .never : .words)
                .font(AppTypography.body)

                if isSecure {
                    Button {
                        isSecureTextVisible.toggle()
                    } label: {
                        Image(systemName: isSecureTextVisible ? "eye.slash" : "eye")
                            .foregroundStyle(AppTheme.textSecondary)
                            .frame(width: AppSizes.minTouchTarget, height: AppSizes.minTouchTarget)
                    }
                    .accessibilityLabel(isSecureTextVisible ? "Hide password" : "Show password")
                }
            }
            .padding(.horizontal, AppSpacing.sm)
            .frame(height: AppSizes.buttonHeight)
            .background(AppTheme.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous)
                    .stroke(borderColor, lineWidth: isFocused || errorMessage != nil ? 1.5 : 0)
            )

            if let errorMessage {
                ErrorView(message: errorMessage)
            }
        }
        .animation(AppAnimation.fast, value: errorMessage)
    }

    private var borderColor: Color {
        errorMessage != nil ? AppTheme.error : AppTheme.primary
    }
}

#Preview {
    VStack(spacing: AppSpacing.md) {
        AppTextField(title: "Email", placeholder: "you@example.com", text: .constant(""), keyboardType: .emailAddress)
        AppTextField(title: "Password", placeholder: "Password", text: .constant("abc"), isSecure: true)
        AppTextField(title: "Email", placeholder: "you@example.com", text: .constant("bad"), errorMessage: "Enter a valid email address.")
    }
    .padding()
}
