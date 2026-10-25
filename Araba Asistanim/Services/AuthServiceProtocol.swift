import Foundation

/// Abstraction over the authentication backend. AuthRepository depends on this
/// protocol, not on a concrete implementation, so MockAuthService can be
/// swapped for a real backend (see `FirebaseAuthService`) without touching
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
    func signOut() throws
    /// Permanently deletes the signed-in account.
    func deleteAccount() async throws
    /// Whether the backend itself still considers a user signed in. A session
    /// persisted by AuthRepository is only restored when this is true, so the
    /// app can't show a user the backend has already signed out.
    var hasActiveSession: Bool { get }
}

extension AuthServiceProtocol {
    var hasActiveSession: Bool { true }
}
