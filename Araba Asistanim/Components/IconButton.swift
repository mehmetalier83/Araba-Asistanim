import SwiftUI

/// A circular icon-only control (settings gear, back arrow, etc.) held to the
/// HIG minimum 44x44 touch target regardless of the icon's own visual size.
struct IconButton: View {
    let systemImage: String
    let accessibilityLabel: String
    var style: Style = .subtle
    let action: () -> Void

    enum Style {
        case subtle
        case prominent
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: AppSizes.iconMedium * 0.7, weight: .semibold))
                .foregroundStyle(foregroundColor)
                .frame(width: AppSizes.minTouchTarget, height: AppSizes.minTouchTarget)
                .background(backgroundColor)
                .clipShape(Circle())
        }
        .buttonStyle(.appPressScale)
        .accessibilityLabel(accessibilityLabel)
    }

    private var foregroundColor: Color {
        switch style {
        case .subtle: return AppTheme.textPrimary
        case .prominent: return AppTheme.primary
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .subtle: return AppTheme.secondaryBackground
        case .prominent: return AppTheme.primarySubtle
        }
    }
}

#Preview {
    HStack(spacing: AppSpacing.md) {
        IconButton(systemImage: "gearshape.fill", accessibilityLabel: "Settings") {}
        IconButton(systemImage: "chevron.left", accessibilityLabel: "Back", style: .prominent) {}
    }
    .padding()
}
