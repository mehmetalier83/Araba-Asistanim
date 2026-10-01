import Foundation

/// Abstraction over the authentication backend. AuthRepository depends on this
/// protocol, not on a concrete implementation, so MockAuthService can be
/// swapped for a real ASP.NET-backed implementation later without touching
/// any other layer.
protocol AuthServiceProtocol {
    func signIn(email: String, password: String) async throws -> (user: User, token: AuthToken)
    /// Registration asks for nothing beyond email and password — a display
    /// name is derived from the email's local part rather than asked for up
    /// front, same as every "quick signup" flow this one is modeled after.
    func signUp(email: String, password: String) async throws -> (user: User, token: AuthToken)
    func signInWithGoogle() async throws -> (user: User, token: AuthToken)
    func signInWithApple() async throws -> (user: User, token: AuthToken)
    func requestPasswordReset(email: String) async throws
}
