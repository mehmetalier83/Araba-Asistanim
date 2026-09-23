import Combine
import Foundation

/// The single source of truth for session state, shared app-wide via the
/// environment. Screens never talk to AuthRepository/AuthService directly.
@MainActor
final class AuthViewModel: ObservableObject {
    @Published private(set) var state: AuthenticationState

    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
        if let session = repository.restoreSession(), !session.token.isExpired {
            state = .authenticated(session.user)
        } else {
            state = .unauthenticated
        }
    }

    var currentUser: User? {
        if case .authenticated(let user) = state { return user }
        return nil
    }

    var isAuthenticating: Bool { state == .authenticating }

    var errorMessage: String? {
        if case .error(let message) = state { return message }
        return nil
    }

    func signIn(email: String, password: String) async {
        state = .authenticating
        do {
            let user = try await repository.signIn(email: email, password: password)
            state = .authenticated(user)
            HapticFeedback.success()
        } catch {
            state = .error(Self.message(for: error))
            HapticFeedback.error()
        }
    }

    func signUp(firstName: String, lastName: String, email: String, password: String) async {
        state = .authenticating
        do {
            let user = try await repository.signUp(
                firstName: firstName, lastName: lastName, email: email, password: password
            )
            state = .authenticated(user)
            HapticFeedback.success()
        } catch {
            state = .error(Self.message(for: error))
            HapticFeedback.error()
        }
    }

    /// Forgot Password doesn't change session state — it's a side action, not
    /// an authentication attempt — so the caller handles its own loading/error
    /// UI rather than observing `state`.
    func requestPasswordReset(email: String) async throws {
        try await repository.requestPasswordReset(email: email)
    }

    func signOut() {
        repository.signOut()
        state = .unauthenticated
    }

    /// Clears a stale `.error` back to `.unauthenticated` — called when the
    /// user edits a field after a failed attempt, so the error doesn't linger.
    func clearError() {
        if case .error = state {
            state = .unauthenticated
        }
    }

    private static func message(for error: Error) -> String {
        (error as? AuthError)?.errorDescription ?? AuthError.unknown.errorDescription ?? "Something went wrong."
    }
}
