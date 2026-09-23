import Foundation

/// TEMPORARY in-memory auth backend so the UI is fully functional before the
/// real ASP.NET API exists. Simulates realistic network latency and the error
/// cases a real backend would return. Seeded with one demo account so Login
/// can be exercised immediately without registering first.
final class MockAuthService: AuthServiceProtocol {
    private struct StoredAccount {
        let user: User
        let password: String
    }

    private var accounts: [String: StoredAccount] = [
        "demo@carlogai.com": StoredAccount(
            user: User(id: UUID(), firstName: "Demo", lastName: "Driver", email: "demo@carlogai.com"),
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

    func signUp(firstName: String, lastName: String, email: String, password: String) async throws -> (user: User, token: AuthToken) {
        try await simulateLatency()

        let key = email.normalizedEmail
        guard accounts[key] == nil else {
            throw AuthError.emailAlreadyInUse
        }
        guard PasswordRequirement.allSatisfied(by: password) else {
            throw AuthError.weakPassword
        }

        let user = User(id: UUID(), firstName: firstName, lastName: lastName, email: email)
        accounts[key] = StoredAccount(user: user, password: password)
        return (user, Self.makeToken())
    }

    func requestPasswordReset(email: String) async throws {
        try await simulateLatency()
        // Intentionally succeeds even for unknown emails, matching real-world
        // password reset UX that avoids confirming which emails are registered.
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
}

private extension String {
    var normalizedEmail: String {
        trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
