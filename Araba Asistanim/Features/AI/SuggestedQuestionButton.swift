import SwiftUI

/// A tappable chip that inserts a predefined question into the conversation.
struct SuggestedQuestionButton: View {
    let question: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(question)
                .font(AppTypography.subheadline)
                .foregroundStyle(AppTheme.primary)
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.xs)
                .background(AppTheme.primarySubtle)
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.pill, style: .continuous))
        }
        .accessibilityLabel("Ask: \(question)")
    }
}

#Preview {
    VStack(alignment: .leading, spacing: AppSpacing.xs) {
        ForEach(PreviewData.suggestedQuestions, id: \.self) { question in
            SuggestedQuestionButton(question: question) {}
        }
    }
    .padding()
}
