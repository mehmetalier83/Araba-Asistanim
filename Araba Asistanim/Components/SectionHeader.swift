import SwiftUI

/// A titled header for grouping content within a screen, with an optional
/// trailing action such as "See All".
struct SectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(AppTypography.headline)
                .foregroundStyle(AppTheme.textPrimary)

            Spacer()

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(AppTypography.subheadline)
                    .foregroundStyle(AppTheme.primary)
            }
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: AppSpacing.lg) {
        SectionHeader(title: "Recent Vehicles")
        SectionHeader(title: "Upcoming Reminders", actionTitle: "See All") {}
    }
    .padding()
}
