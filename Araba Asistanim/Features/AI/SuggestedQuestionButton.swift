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
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.xs + 2)
                .background(AppTheme.cardBackground, in: Capsule())
                .overlay(Capsule().stroke(AppTheme.primary.opacity(0.3), lineWidth: 1))
        }
        .buttonStyle(.appPressScale)
        .accessibilityLabel("Sor: \(question)")
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
