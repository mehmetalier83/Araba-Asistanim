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
}
