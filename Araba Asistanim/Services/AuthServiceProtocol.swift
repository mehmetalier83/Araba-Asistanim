import Foundation

/// Abstraction over the authentication backend. AuthRepository depends on this
/// protocol, not on a concrete implementation, so MockAuthService can be
/// swapped for a real ASP.NET-backed implementation later without touching
/// any other layer.
protocol AuthServiceProtocol {
    func signIn(email: String, password: String) async throws -> (user: User, token: AuthToken)
    func signUp(firstName: String, lastName: String, email: String, password: String) async throws -> (user: User, token: AuthToken)
    func requestPasswordReset(email: String) async throws
}
