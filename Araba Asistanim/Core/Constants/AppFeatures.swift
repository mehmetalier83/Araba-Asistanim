import Foundation

/// Switches for features that are built but not turned on yet.
enum AppFeatures {
    /// Sign in with Apple needs the capability on a paid developer team and the
    /// Apple provider enabled in Firebase. Flip to `true` once both are set up;
    /// the sign-in code is already in place (`AppleSignInCoordinator`).
    static let appleSignInEnabled = false
}
