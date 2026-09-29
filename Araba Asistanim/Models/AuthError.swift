import Foundation

/// User-facing authentication errors. Every case carries its own friendly copy —
/// callers should never surface a raw underlying error (e.g. a URLSession or
/// Keychain status code) directly to the UI.
enum AuthError: LocalizedError, Equatable {
    case invalidCredentials
    case emailAlreadyInUse
    case weakPassword
    case network
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
        case .unknown:
            return "Bir şeyler ters gitti. Lütfen tekrar dene."
        }
    }
}
