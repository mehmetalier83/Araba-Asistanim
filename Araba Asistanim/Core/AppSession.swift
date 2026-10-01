import Foundation

/// Tracks whether the current session should be seeded with demo content.
/// Only the built-in `demo@carlogai.com` account gets the sample garage
/// (BMW 320i, its maintenance history, expenses, etc.) — every other
/// account, whether freshly registered or signed in via Google/Apple,
/// starts with a genuinely empty garage, exactly like a brand-new user who
/// hasn't added anything yet. `AuthViewModel` sets this the moment a session
/// becomes authenticated (sign in, sign up, social sign-in, and session
/// restore alike), before any tab's view models are constructed.
@MainActor
enum AppSession {
    static var isDemoAccount = false

    static func update(for user: User) {
        isDemoAccount = user.email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "demo@carlogai.com"
    }
}
