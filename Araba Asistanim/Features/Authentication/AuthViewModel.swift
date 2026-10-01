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
        // A device that has ever signed in stays signed in — only a fresh
        // install (no persisted session) should see the Welcome/Login flow.
        // We deliberately don't gate this on access-token expiry: with a real
        // backend an expired access token is silently renewed from the
        // refresh token, never bouncing the user back to login. MockAuthService
        // doesn't implement that refresh call yet, so for now a persisted
        // session is treated as valid until the user explicitly logs out.
        if let session = repository.restoreSession() {
            AppSession.update(for: session.user)
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
            authenticate(as: user)
        } catch {
            state = .error(Self.message(for: error))
            HapticFeedback.error()
        }
    }

    func signUp(email: String, password: String) async {
        state = .authenticating
        do {
            let user = try await repository.signUp(email: email, password: password)
            authenticate(as: user)
        } catch {
            state = .error(Self.message(for: error))
            HapticFeedback.error()
        }
    }

    func signInWithGoogle() async {
        state = .authenticating
        do {
            let user = try await repository.signInWithGoogle()
            authenticate(as: user)
        } catch {
            state = .error(Self.message(for: error))
            HapticFeedback.error()
        }
    }

    func signInWithApple() async {
        state = .authenticating
        do {
            let user = try await repository.signInWithApple()
            authenticate(as: user)
        } catch {
            state = .error(Self.message(for: error))
            HapticFeedback.error()
        }
    }

    /// Sets the demo-vs-empty data flag before publishing `.authenticated`,
    /// so every tab's view models see the correct flag the first time they're
    /// constructed (which happens as soon as `AppRootView` switches to
    /// `MainTabView` in response to this state change).
    private func authenticate(as user: User) {
        AppSession.update(for: user)
        state = .authenticated(user)
        HapticFeedback.success()
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
        (error as? AuthError)?.errorDescription ?? AuthError.unknown.errorDescription ?? "Bir şeyler ters gitti."
    }
}
