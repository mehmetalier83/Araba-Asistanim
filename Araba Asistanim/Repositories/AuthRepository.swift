import Foundation

/// Coordinates the auth backend (AuthServiceProtocol) with secure token
/// persistence (SecureStorage). ViewModels talk to this, never to the service
/// or Keychain directly — this is the only place that knows tokens belong in
/// the Keychain and the user profile belongs in UserDefaults.
final class AuthRepository {
    private enum Key {
        static let accessToken = "auth.accessToken"
        static let refreshToken = "auth.refreshToken"
        static let expiresAt = "auth.expiresAt"
        static let currentUser = "auth.currentUser"
    }

    private let service: AuthServiceProtocol
    private let secureStorage: SecureStorage
    private let userDefaults: UserDefaults

    init(
        service: AuthServiceProtocol,
        secureStorage: SecureStorage,
        userDefaults: UserDefaults = .standard
    ) {
        self.service = service
        self.secureStorage = secureStorage
        self.userDefaults = userDefaults
    }

    /// Restores a session left over from a previous launch, if any tokens are
    /// still present in the Keychain. Returns `nil` for a clean, logged-out start.
    func restoreSession() -> (user: User, token: AuthToken)? {
        guard
            let userData = userDefaults.data(forKey: Key.currentUser),
            let user = try? JSONDecoder().decode(User.self, from: userData),
            let accessToken = try? secureStorage.read(for: Key.accessToken),
            let refreshToken = try? secureStorage.read(for: Key.refreshToken),
            let expiresAtString = try? secureStorage.read(for: Key.expiresAt),
            let expiresAtInterval = TimeInterval(expiresAtString)
        else {
            return nil
        }

        let token = AuthToken(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresAt: Date(timeIntervalSince1970: expiresAtInterval)
        )
        return (user, token)
    }

    func signIn(email: String, password: String) async throws -> User {
        let (user, token) = try await service.signIn(email: email, password: password)
        try persist(user: user, token: token)
        return user
    }

    func signUp(firstName: String, lastName: String, email: String, password: String) async throws -> User {
        let (user, token) = try await service.signUp(
            firstName: firstName, lastName: lastName, email: email, password: password
        )
        try persist(user: user, token: token)
        return user
    }

    func requestPasswordReset(email: String) async throws {
        try await service.requestPasswordReset(email: email)
    }

    func signOut() {
        try? secureStorage.delete(for: Key.accessToken)
        try? secureStorage.delete(for: Key.refreshToken)
        try? secureStorage.delete(for: Key.expiresAt)
        userDefaults.removeObject(forKey: Key.currentUser)
    }

    private func persist(user: User, token: AuthToken) throws {
        try secureStorage.save(token.accessToken, for: Key.accessToken)
        try secureStorage.save(token.refreshToken, for: Key.refreshToken)
        try secureStorage.save(String(token.expiresAt.timeIntervalSince1970), for: Key.expiresAt)

        let userData = try JSONEncoder().encode(user)
        userDefaults.set(userData, forKey: Key.currentUser)
    }
}
