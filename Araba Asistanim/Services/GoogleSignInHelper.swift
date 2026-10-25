import FirebaseCore
import Foundation
import UIKit

/// Checks needed before starting Google Sign-In: the Firebase app must carry a
/// Google OAuth client ID (present in GoogleService-Info.plist only once the
/// Google provider is enabled in the Firebase console), and the app must
/// register that client's reversed ID as a URL scheme (Config/Info.plist,
/// via the GOOGLE_REVERSED_CLIENT_ID build setting).
enum GoogleSignInHelper {
    static var clientID: String? {
        FirebaseApp.app()?.options.clientID
    }

    static var isConfigured: Bool {
        guard let clientID else { return false }
        let reversed = clientID.split(separator: ".").reversed().joined(separator: ".")
        let urlTypes = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: Any]] ?? []
        let schemes = urlTypes.flatMap { $0["CFBundleURLSchemes"] as? [String] ?? [] }
        return schemes.contains(reversed)
    }

    /// The view controller to present the Google sheet from.
    static var presentingViewController: UIViewController? {
        let root = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .rootViewController
        var top = root
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }
}
