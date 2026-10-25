import FirebaseCore
import FirebaseFirestore
import Foundation

/// Configures Firebase only when `GoogleService-Info.plist` is bundled.
/// `FirebaseApp.configure()` crashes without that file, so a checkout that
/// hasn't added it yet keeps running on MockAuthService instead.
enum FirebaseBootstrap {
    /// A plain flag: `FirebaseApp.app()` logs an error when nothing is configured.
    private(set) static var isConfigured = false

    static func configureIfAvailable() -> Bool {
        if isConfigured { return true }
        guard Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil else {
            return false
        }
        FirebaseApp.configure()
        isConfigured = true

        // Offline-first: reads come from the local cache when there's no
        // connection, and writes sync once the device is back online.
        let settings = FirestoreSettings()
        settings.cacheSettings = PersistentCacheSettings()
        Firestore.firestore().settings = settings
        return true
    }
}
