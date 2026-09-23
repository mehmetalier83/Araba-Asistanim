import UIKit

/// Thin wrapper around UIKit's feedback generators. Used sparingly — only for
/// genuinely significant confirmations (successful auth, logout), never on
/// every tap, per the app's restrained interaction design.
enum HapticFeedback {
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}
