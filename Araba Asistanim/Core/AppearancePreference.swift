import SwiftUI

/// The user's light/dark theme choice, persisted via `@AppStorage`.
enum AppearancePreference: String, CaseIterable, Identifiable {
    static let storageKey = "appearancePreference"

    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: return "Sistem"
        case .light: return "Açık"
        case .dark: return "Koyu"
        }
    }

    /// `nil` follows the system setting.
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
