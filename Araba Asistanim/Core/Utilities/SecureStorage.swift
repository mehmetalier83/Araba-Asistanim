import Foundation
import Security

/// Abstraction over secure key/value storage. Access and refresh tokens must
/// never be written to UserDefaults — this protocol exists so the real
/// Keychain-backed implementation can be swapped for an in-memory fake in
/// previews and tests.
protocol SecureStorage {
    func save(_ value: String, for key: String) throws
    func read(for key: String) throws -> String?
    func delete(for key: String) throws
}

enum SecureStorageError: LocalizedError {
    case encodingFailed
    case unhandled(OSStatus)

    var errorDescription: String? {
        "Something went wrong. Please try again."
    }
}

/// Keychain-backed SecureStorage. Used for auth tokens; each value is scoped to
/// this app via `kSecAttrService` and is only available after the device has
/// been unlocked once since boot (`kSecAttrAccessibleAfterFirstUnlock`), which
/// still allows background token refresh while avoiding storage before the
/// user's first unlock.
final class KeychainService: SecureStorage {
    private let service: String

    init(service: String = Bundle.main.bundleIdentifier ?? "com.carlogai.app") {
        self.service = service
    }

    func save(_ value: String, for key: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw SecureStorageError.encodingFailed
        }

        let query = baseQuery(for: key)
        SecItemDelete(query as CFDictionary)

        var attributes = query
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock

        let status = SecItemAdd(attributes as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw SecureStorageError.unhandled(status)
        }
    }

    func read(for key: String) throws -> String? {
        var query = baseQuery(for: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound {
            return nil
        }
        guard status == errSecSuccess, let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            throw SecureStorageError.unhandled(status)
        }
        return value
    }

    func delete(for key: String) throws {
        let status = SecItemDelete(baseQuery(for: key) as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw SecureStorageError.unhandled(status)
        }
    }

    private func baseQuery(for key: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
    }
}

/// A non-persistent SecureStorage used in SwiftUI previews and unit tests, so
/// neither has to touch the real Keychain.
final class InMemorySecureStorage: SecureStorage {
    private var storage: [String: String] = [:]

    func save(_ value: String, for key: String) throws { storage[key] = value }
    func read(for key: String) throws -> String? { storage[key] }
    func delete(for key: String) throws { storage.removeValue(forKey: key) }
}
