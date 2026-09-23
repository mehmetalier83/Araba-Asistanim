import Foundation

/// Push destinations within the unauthenticated flow.
enum AuthRoute: Hashable {
    case login
    case register
    case forgotPassword
}
