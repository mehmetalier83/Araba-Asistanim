import SwiftUI

/// User messages are mascot-gradient bubbles (something *they* said); the
/// assistant answers on a card next to a small mascot avatar.
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
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.sm)
                    .background(
                        LinearGradient.primaryButton(),
                        in: UnevenRoundedRectangle(topLeadingRadius: 20, bottomLeadingRadius: 20, bottomTrailingRadius: 6, topTrailingRadius: 20, style: .continuous)
                    )
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Sen: \(message.text)")
        } else {
            HStack(alignment: .top, spacing: AppSpacing.xs) {
                CarMascot(animates: false, glows: false)
                    .padding(4)
                    .frame(width: 32, height: 32)
                    .background(LinearGradient.mascot(), in: Circle())
                    .accessibilityHidden(true)

                Text(message.text)
                    .font(AppTypography.body)
                    .foregroundStyle(AppTheme.textPrimary)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.sm)
                    .background(
                        AppTheme.cardBackground,
                        in: UnevenRoundedRectangle(topLeadingRadius: 6, bottomLeadingRadius: 20, bottomTrailingRadius: 20, topTrailingRadius: 20, style: .continuous)
                    )
                    .overlay(
                        UnevenRoundedRectangle(topLeadingRadius: 6, bottomLeadingRadius: 20, bottomTrailingRadius: 20, topTrailingRadius: 20, style: .continuous)
                            .stroke(AppColors.surfaceStroke, lineWidth: 1)
                    )
                    .appShadow(AppShadow.card)

                Spacer(minLength: AppSizes.iconLarge)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Asistan: \(message.text)")
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
