import SwiftUI

/// Centralized animation durations. Kept fast and subtle by design — motion should
/// confirm an interaction, not decorate it. Every use should be wrapped with
/// `withReducedMotion` (or check `UIAccessibility.isReduceMotionEnabled`) so Reduce
/// Motion users get an instant state change instead of a suppressed animation.
enum AppAnimation {
    static let fast = Animation.easeOut(duration: 0.15)
    static let standard = Animation.easeInOut(duration: 0.25)
    static let spring = Animation.spring(response: 0.35, dampingFraction: 0.85)
}

extension Animation {
    /// Returns `self` normally, or `nil` (no animation) when Reduce Motion is on.
    static func respectingReduceMotion(_ animation: Animation) -> Animation? {
        UIAccessibility.isReduceMotionEnabled ? nil : animation
    }
}
