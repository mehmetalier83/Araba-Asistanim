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
            return "Incorrect email or password."
        case .emailAlreadyInUse:
            return "An account with this email already exists."
        case .weakPassword:
            return "Your password doesn't meet the requirements."
        case .network:
            return "Unable to connect. Please check your internet connection and try again."
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
}
