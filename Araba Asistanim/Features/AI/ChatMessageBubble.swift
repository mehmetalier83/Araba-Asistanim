import SwiftUI

/// User and assistant messages are deliberately styled with different
/// hierarchy: the user's message is a filled bubble (something *they* said),
/// while the assistant's reply reads as plain inline text with a small marker
/// icon — closer to an answer the app is surfacing than a chat bubble. This
/// keeps the AI feeling like an integrated feature rather than the visual
/// focus of the app.
struct ChatMessageBubble: View {
    let message: ChatMessage

    private var isUser: Bool { message.role == .user }

    var body: some View {
        if isUser {
            HStack {
                Spacer(minLength: AppSizes.iconHero)

                Text(message.text)
                    .font(AppTypography.body)
                    .foregroundStyle(.white)
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, AppSpacing.xs)
                    .background(AppTheme.primary)
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("You said: \(message.text)")
        } else {
            HStack(alignment: .top, spacing: AppSpacing.xs) {
                Image(systemName: "sparkles")
                    .font(.system(size: AppSizes.iconXSmall))
                    .foregroundStyle(AppTheme.primary)
                    .padding(.top, 3)
                    .accessibilityHidden(true)

                Text(message.text)
                    .font(AppTypography.body)
                    .foregroundStyle(AppTheme.textPrimary)

                Spacer(minLength: AppSizes.iconHero)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Assistant said: \(message.text)")
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: AppSpacing.sm) {
        ChatMessageBubble(message: PreviewData.initialAssistantMessage)
        ChatMessageBubble(message: ChatMessage(role: .user, text: "What maintenance is coming up?"))
    }
    .padding()
}

#Preview("Dark") {
    VStack(alignment: .leading, spacing: AppSpacing.sm) {
        ChatMessageBubble(message: PreviewData.initialAssistantMessage)
        ChatMessageBubble(message: ChatMessage(role: .user, text: "What maintenance is coming up?"))
    }
    .padding()
    .preferredColorScheme(.dark)
}
