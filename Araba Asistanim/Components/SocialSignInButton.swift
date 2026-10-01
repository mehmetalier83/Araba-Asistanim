import SwiftUI

/// A "Continue with Google/Apple" button. Apple's button stays fixed black —
/// one of Apple's own approved HIG styles, not theme-tinted — while Google's
/// uses the app's dynamic secondary-background pill so it adapts to dark mode
/// like every other field in the app.
struct SocialSignInButton: View {
    enum Provider {
        case google
        case apple

        var title: String {
            switch self {
            case .google: return "Google ile Devam Et"
            case .apple: return "Apple ile Devam Et"
            }
        }
    }

    let provider: Provider
    var isLoading: Bool = false
    let action: () -> Void

    private var isInteractive: Bool { !isLoading }

    var body: some View {
        Button(action: action) {
            ZStack {
                HStack(spacing: AppSpacing.xs) {
                    icon
                    Text(provider.title)
                        .font(AppTypography.headline)
                }
                .opacity(isLoading ? 0 : 1)

                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(foregroundColor)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: AppSizes.buttonHeight)
        }
        .buttonStyle(.appPressScale)
        .foregroundStyle(foregroundColor)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous)
                .stroke(AppTheme.border, lineWidth: provider == .google ? 1 : 0)
        )
        .disabled(!isInteractive)
        .accessibilityLabel(provider.title)
        .accessibilityValue(isLoading ? "Yükleniyor" : "")
    }

    @ViewBuilder
    private var icon: some View {
        switch provider {
        case .apple:
            Image(systemName: "apple.logo")
                .font(.system(size: AppSizes.iconSmall, weight: .medium))
        case .google:
            Text("G")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color(hex: 0x4285F4))
        }
    }

    private var foregroundColor: Color {
        provider == .apple ? .white : AppTheme.textPrimary
    }

    private var backgroundColor: Color {
        provider == .apple ? .black : AppTheme.secondaryBackground
    }
}

#Preview {
    VStack(spacing: AppSpacing.sm) {
        SocialSignInButton(provider: .apple) {}
        SocialSignInButton(provider: .google) {}
        SocialSignInButton(provider: .google, isLoading: true) {}
    }
    .padding()
}

#Preview("Dark") {
    VStack(spacing: AppSpacing.sm) {
        SocialSignInButton(provider: .apple) {}
        SocialSignInButton(provider: .google) {}
    }
    .padding()
    .preferredColorScheme(.dark)
}
