import Foundation

/// TEMPORARY in-memory auth backend so the UI is fully functional before the
/// real ASP.NET API exists. Simulates realistic network latency and the error
/// cases a real backend would return. Seeded with one demo account so Login
/// can be exercised immediately without registering first.
final class MockAuthService: AuthServiceProtocol {
    private struct StoredAccount {
        let user: User
        let password: String?
    }

    private var accounts: [String: StoredAccount] = [
        "demo@carlogai.com": StoredAccount(
            user: User(id: UUID(), firstName: "Demo", lastName: "Sürücü", email: "demo@carlogai.com"),
            password: "Password1"
        )
    ]

    func signIn(email: String, password: String) async throws -> (user: User, token: AuthToken) {
        try await simulateLatency()

        guard let account = accounts[email.normalizedEmail], account.password == password else {
            throw AuthError.invalidCredentials
        }
        return (account.user, Self.makeToken())
    }

    func signUp(email: String, password: String) async throws -> (user: User, token: AuthToken) {
        try await simulateLatency()

        let key = email.normalizedEmail
        guard accounts[key] == nil else {
            throw AuthError.emailAlreadyInUse
        }
        guard PasswordRequirement.allSatisfied(by: password) else {
            throw AuthError.weakPassword
        }

        let (firstName, lastName) = Self.displayName(fromEmail: email)
        let user = User(id: UUID(), firstName: firstName, lastName: lastName, email: email)
        accounts[key] = StoredAccount(user: user, password: password)
        return (user, Self.makeToken())
    }

    /// Simulates the one-tap "Continue with Google" flow: no password, no
    /// form — the same mock Google identity is returned (and reused) every
    /// time, same as a real OAuth provider would always hand back the same
    /// account for that device's signed-in Google user.
    func signInWithGoogle() async throws -> (user: User, token: AuthToken) {
        try await simulateLatency()
        return (socialAccount(
            key: "google:kullanici@gmail.com",
            firstName: "Google",
            lastName: "Kullanıcısı",
            email: "kullanici@gmail.com"
        ), Self.makeToken())
    }

    /// Mirrors Apple's real private-relay email shape so the mock reads as
    /// authentic rather than a placeholder.
    func signInWithApple() async throws -> (user: User, token: AuthToken) {
        try await simulateLatency()
        return (socialAccount(
            key: "apple:kullanici@privaterelay.appleid.com",
            firstName: "Apple",
            lastName: "Kullanıcısı",
            email: "kullanici@privaterelay.appleid.com"
        ), Self.makeToken())
    }

    func requestPasswordReset(email: String) async throws {
        try await simulateLatency()
        // Intentionally succeeds even for unknown emails, matching real-world
        // password reset UX that avoids confirming which emails are registered.
    }

    /// Returns the existing mock social account if this provider was already
    /// used on this device, or mints and stores a new one — so repeated
    /// "Continue with Google" taps keep resolving to the same `User.id`
    /// instead of a fresh identity every time.
    private func socialAccount(key: String, firstName: String, lastName: String, email: String) -> User {
        if let existing = accounts[key] {
            return existing.user
        }
        let user = User(id: UUID(), firstName: firstName, lastName: lastName, email: email)
        accounts[key] = StoredAccount(user: user, password: nil)
        return user
    }

    private func simulateLatency() async throws {
        try await Task.sleep(for: .milliseconds(700))
    }

    private static func makeToken() -> AuthToken {
        AuthToken(
            accessToken: "mock-access-\(UUID().uuidString)",
            refreshToken: "mock-refresh-\(UUID().uuidString)",
            expiresAt: .now.addingTimeInterval(3600)
        )
    }

    /// Turns "ayse.yilmaz@example.com" into ("Ayse", "Yilmaz") — a reasonable
    /// placeholder display name derived purely from the email, since
    /// registration no longer asks for one.
    private static func displayName(fromEmail email: String) -> (first: String, last: String) {
        let localPart = email.split(separator: "@").first.map(String.init) ?? email
        let parts = localPart
            .split(whereSeparator: { ".-_+".contains($0) })
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }

        guard let first = parts.first, !first.isEmpty else {
            return ("Kullanıcı", "")
        }
        let last = parts.dropFirst().joined(separator: " ")
        return (first, last)
    }
}

private extension String {
    var normalizedEmail: String {
        trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
