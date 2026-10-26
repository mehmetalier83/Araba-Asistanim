import SwiftUI

/// A generic container that applies the app's standard card styling
/// (card surface, generous padding, large radius) around any content.
struct CardView<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(AppSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .appCard()
    }
}

#Preview {
    CardView {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Card title")
                .font(AppTypography.headline)
            Text("Some supporting detail text.")
                .font(AppTypography.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
        }
    }
    .padding()
}
