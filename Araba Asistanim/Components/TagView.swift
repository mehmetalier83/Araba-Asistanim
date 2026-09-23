import SwiftUI

/// A small status pill (e.g. "Overdue", "Due Soon", "Completed"). Uses a tinted
/// background rather than a saturated fill so status color reads as information,
/// not decoration — and never relies on color alone (the text always says what
/// the status is).
struct TagView: View {
    let text: String
    var tone: Tone = .neutral

    enum Tone {
        case neutral
        case accent
        case success
        case warning
        case danger

        var foreground: Color {
            switch self {
            case .neutral: return AppTheme.textSecondary
            case .accent: return AppTheme.primary
            case .success: return AppTheme.success
            case .warning: return AppTheme.warning
            case .danger: return AppTheme.error
            }
        }

        var background: Color {
            switch self {
            case .neutral: return AppTheme.secondaryBackground
            case .accent: return AppTheme.primarySubtle
            case .success: return AppTheme.successSubtle
            case .warning: return AppTheme.warningSubtle
            case .danger: return AppTheme.errorSubtle
            }
        }
    }

    var body: some View {
        Text(text)
            .font(AppTypography.captionEmphasized)
            .foregroundStyle(tone.foreground)
            .padding(.horizontal, AppSpacing.xs)
            .padding(.vertical, 4)
            .background(tone.background)
            .clipShape(Capsule())
    }
}

#Preview {
    HStack(spacing: AppSpacing.xs) {
        TagView(text: "Completed", tone: .success)
        TagView(text: "Due Soon", tone: .warning)
        TagView(text: "Overdue", tone: .danger)
        TagView(text: "Hybrid", tone: .neutral)
    }
    .padding()
}
