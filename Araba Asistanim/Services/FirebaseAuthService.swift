import FirebaseAuth
import Foundation
import GoogleSignIn

/// AuthServiceProtocol backed by Firebase Authentication. Firebase keeps its
/// own session (and silently refreshes the ID token), so the token handed
/// back here is only what AuthRepository persists for the rest of the app.
final class FirebaseAuthService: AuthServiceProtocol {
    private var auth: Auth { Auth.auth() }
    private let appleSignIn = AppleSignInCoordinator()

    var hasActiveSession: Bool { auth.currentUser != nil }

    func signIn(email: String, password: String) async throws -> (user: User, token: AuthToken) {
        do {
            let result = try await auth.signIn(withEmail: email.trimmed, password: password)
            return try await session(for: result.user)
        } catch {
            throw Self.map(error)
        }
    }

    func signUp(email: String, password: String) async throws -> (user: User, token: AuthToken) {
        guard PasswordRequirement.allSatisfied(by: password) else {
            throw AuthError.weakPassword
        }
        do {
            let result = try await auth.createUser(withEmail: email.trimmed, password: password)
            let (first, last) = User.displayName(fromEmail: email)
            let change = result.user.createProfileChangeRequest()
            change.displayName = [first, last].filter { !$0.isEmpty }.joined(separator: " ")
            try? await change.commitChanges()
            return try await session(for: result.user)
        } catch {
            throw Self.map(error)
        }
    }

    /// Requires the Google provider enabled in the Firebase console (which
    /// adds CLIENT_ID to GoogleService-Info.plist) and the matching URL
    /// scheme — see `GoogleSignInHelper`.
    func signInWithGoogle() async throws -> (user: User, token: AuthToken) {
        guard GoogleSignInHelper.isConfigured, let clientID = GoogleSignInHelper.clientID else {
            throw AuthError.providerUnavailable
        }
        guard let presenter = GoogleSignInHelper.presentingViewController else {
            throw AuthError.unknown
        }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenter)
            guard let idToken = result.user.idToken?.tokenString else { throw AuthError.unknown }
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            let authResult = try await auth.signIn(with: credential)
            return try await session(for: authResult.user)
        } catch let error as GIDSignInError where error.code == .canceled {
            throw AuthError.cancelled
        } catch {
            throw Self.map(error)
        }
    }

    /// Requires the "Sign in with Apple" capability on the target and the
    /// Apple provider enabled in the Firebase console.
    func signInWithApple() async throws -> (user: User, token: AuthToken) {
        do {
            let apple = try await appleSignIn.signIn()
            let credential = OAuthProvider.appleCredential(
                withIDToken: apple.idToken,
                rawNonce: apple.rawNonce,
                fullName: apple.fullName
            )
            let result = try await auth.signIn(with: credential)
            return try await session(for: result.user, fallbackName: apple.fullName)
        } catch {
            throw Self.map(error)
        }
    }

    func requestPasswordReset(email: String) async throws {
        do {
            try await auth.sendPasswordReset(withEmail: email.trimmed)
        } catch {
            let mapped = Self.map(error)
            // Same as the mock: don't reveal whether an email is registered.
            if mapped == .invalidCredentials { return }
            throw mapped
        }
    }

    func signOut() throws {
        GIDSignIn.sharedInstance.signOut()
        try auth.signOut()
    }

    func deleteAccount() async throws {
        guard let user = auth.currentUser else { throw AuthError.unknown }
        do {
            try await user.delete()
        } catch {
            throw Self.map(error)
        }
    }

    // MARK: - Helpers

    private func session(
        for firebaseUser: FirebaseAuth.User,
        fallbackName: PersonNameComponents? = nil
    ) async throws -> (user: User, token: AuthToken) {
        let tokenResult = try await firebaseUser.getIDTokenResult()
        let email = firebaseUser.email ?? ""

        let (first, last): (String, String)
        if let displayName = firebaseUser.displayName, !displayName.isEmpty {
            var parts = displayName.split(separator: " ").map(String.init)
            let firstPart = parts.removeFirst()
            (first, last) = (firstPart, parts.joined(separator: " "))
        } else if let given = fallbackName?.givenName {
            (first, last) = (given, fallbackName?.familyName ?? "")
        } else {
            (first, last) = User.displayName(fromEmail: email)
        }

        let user = User(id: firebaseUser.uid, firstName: first, lastName: last, email: email)
        let token = AuthToken(
            accessToken: tokenResult.token,
            refreshToken: firebaseUser.refreshToken ?? "",
            expiresAt: tokenResult.expirationDate
        )
        return (user, token)
    }

    private static func map(_ error: Error) -> AuthError {
        if let authError = error as? AuthError { return authError }

        let nsError = error as NSError
        guard nsError.domain == AuthErrorDomain, let code = AuthErrorCode(rawValue: nsError.code) else {
            return .unknown
        }
        switch code {
        case .wrongPassword, .invalidCredential, .userNotFound, .invalidEmail, .userDisabled:
            return .invalidCredentials
        case .emailAlreadyInUse, .credentialAlreadyInUse, .accountExistsWithDifferentCredential:
            return .emailAlreadyInUse
        case .weakPassword:
            return .weakPassword
        case .networkError:
            return .network
        case .tooManyRequests:
            return .tooManyRequests
        case .operationNotAllowed:
            return .providerUnavailable
        case .requiresRecentLogin:
            return .requiresRecentLogin
        default:
            return .unknown
        }
    }
}

private extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
