import Foundation

/// The app's session state. AppRootView routes on this: `.authenticated` shows
/// the main tab experience, every other case shows the auth flow (with
/// `.authenticating`/`.error` reflected as in-flow loading/error UI rather than
/// a different top-level screen, so the routing itself never flickers).
enum AuthenticationState: Equatable {
    case unauthenticated
    case authenticating
    case authenticated(User)
    case error(String)
}
