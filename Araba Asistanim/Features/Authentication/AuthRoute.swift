import Foundation

/// Push destinations within the unauthenticated flow.
enum AuthRoute: Hashable {
    case onboarding
    case login
    case register
    case forgotPassword
}
