import SwiftUI
import UIKit

extension Color {
    /// Builds a dynamic color from distinct light/dark values so dark mode can be
    /// intentionally tuned rather than derived by inverting the light palette.
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }

    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}

/// Brand color palette. Neutrals (backgrounds, text, separators) intentionally stay
/// on Apple's semantic system colors elsewhere in AppTheme — those already ship with
/// carefully tuned dark-mode variants and respond to Increased Contrast automatically.
/// This file defines only the colors that make CarLog AI feel like *this* product:
/// the accent and the semantic status colors, each independently tuned per appearance.
enum AppColors {
    /// "Circuit Blue" — a confident, engineered blue rather than default iOS system blue.
    static let accent = Color(
        light: Color(hex: 0x2F5FE0),
        dark: Color(hex: 0x6E97FF)
    )

    static let accentSubtle = Color(
        light: Color(hex: 0x2F5FE0).opacity(0.10),
        dark: Color(hex: 0x6E97FF).opacity(0.16)
    )

    /// Positive / completed / on-track states. Muted, not a saturated "success green".
    static let success = Color(
        light: Color(hex: 0x27835A),
        dark: Color(hex: 0x4CCB8C)
    )

    static let successSubtle = Color(
        light: Color(hex: 0x27835A).opacity(0.10),
        dark: Color(hex: 0x4CCB8C).opacity(0.16)
    )

    /// Upcoming / due-soon states. Warm amber — informative, not alarming.
    static let warning = Color(
        light: Color(hex: 0xB07A1B),
        dark: Color(hex: 0xE0A83C)
    )

    static let warningSubtle = Color(
        light: Color(hex: 0xB07A1B).opacity(0.12),
        dark: Color(hex: 0xE0A83C).opacity(0.18)
    )

    /// Overdue / destructive states only. Used sparingly by design.
    static let danger = Color(
        light: Color(hex: 0xC63C3C),
        dark: Color(hex: 0xFF6B6B)
    )

    static let dangerSubtle = Color(
        light: Color(hex: 0xC63C3C).opacity(0.10),
        dark: Color(hex: 0xFF6B6B).opacity(0.16)
    )

    /// Two additional muted accents for the expanded expense-category palette —
    /// a 12-category picker needs more visual variety than the five core roles
    /// above provide. Tuned per-appearance like the rest of the palette, kept
    /// in the same restrained, non-neon register.
    static let categoryTeal = Color(
        light: Color(hex: 0x1E8A87),
        dark: Color(hex: 0x4FC9C4)
    )

    static let categoryPurple = Color(
        light: Color(hex: 0x6B4FCC),
        dark: Color(hex: 0x9E8AFF)
    )
}

extension LinearGradient {
    /// The primary call-to-action surface — a subtle top-to-bottom deepening
    /// of the accent blue rather than a flat fill, so the main button on
    /// every form reads as a deliberately crafted surface. Kept tight (two
    /// close shades, not a rainbow) to stay within the app's restrained
    /// palette philosophy.
    @MainActor
    static func primaryButton(startPoint: UnitPoint = .top, endPoint: UnitPoint = .bottom) -> LinearGradient {
        LinearGradient(
            colors: [
                Color(light: Color(hex: 0x4472E8), dark: Color(hex: 0x82A6FF)),
                Color(light: Color(hex: 0x2650C9), dark: Color(hex: 0x5A82E0))
            ],
            startPoint: startPoint,
            endPoint: endPoint
        )
    }

    /// The dark "graphite" surface used for every automotive hero element:
    /// the Home vehicle card, the Vehicle Detail header, and Welcome. Same
    /// appearance in both light and dark mode by design — this is a fixed
    /// brand surface, not a themed background.
    @MainActor
    static func graphiteSurface(startPoint: UnitPoint = .topLeading, endPoint: UnitPoint = .bottomTrailing) -> LinearGradient {
        LinearGradient(
            colors: [Color(hex: 0x24304A), Color(hex: 0x05070C)],
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
}
