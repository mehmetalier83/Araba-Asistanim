import Foundation

/// User-facing authentication errors. Every case carries its own friendly copy —
/// callers should never surface a raw underlying error (e.g. a URLSession or
/// Keychain status code) directly to the UI.
enum AuthError: LocalizedError, Equatable {
    case invalidCredentials
    case emailAlreadyInUse
    case weakPassword
    case network
    case tooManyRequests
    /// Sensitive actions (e.g. deleting the account) need a fresh sign-in.
    case requiresRecentLogin
    /// The sign-in provider (e.g. Google) isn't set up for this build yet.
    case providerUnavailable
    /// Sign in with Apple isn't enabled for this build: the app lacks the
    /// capability (it can't be added on a free "Personal Team").
    case appleSignInNotConfigured
    /// The provider is switched off in the Firebase console.
    case providerDisabled
    /// The user dismissed a system sign-in sheet — not shown as an error.
    case cancelled
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "E-posta veya şifre hatalı."
        case .emailAlreadyInUse:
            return "Bu e-posta ile zaten bir hesap var."
        case .weakPassword:
            return "Şifren gereksinimleri karşılamıyor."
        case .network:
            return "Bağlantı kurulamadı. İnternet bağlantını kontrol edip tekrar dene."
        case .tooManyRequests:
            return "Çok fazla deneme yapıldı. Lütfen biraz bekleyip tekrar dene."
        case .requiresRecentLogin:
            return "Güvenliğin için bu işlemden önce çıkış yapıp tekrar giriş yapman gerekiyor."
        case .providerUnavailable:
            return "Bu giriş yöntemi henüz kullanılamıyor. Lütfen e-posta ile giriş yap."
        case .appleSignInNotConfigured:
            return "Apple ile giriş bu sürümde henüz etkin değil. Şimdilik e-posta veya Google ile devam edebilirsin."
        case .providerDisabled:
            return "Bu giriş yöntemi şu an kapalı. Lütfen e-posta veya başka bir yöntemle devam et."
        case .cancelled:
            return "Giriş iptal edildi."
        case .unknown:
            return "Bir şeyler ters gitti. Lütfen tekrar dene."
        }
    }
}
