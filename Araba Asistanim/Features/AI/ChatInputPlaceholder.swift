import SwiftUI

/// A visually present chat input bar. Text entry is not wired to real
/// messaging yet — this phase only supports tapping suggested questions.
struct ChatInputPlaceholder: View {
    @Binding var text: String
    var isSendDisabled: Bool = true

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            TextField("Ask about your vehicle...", text: $text)
                .font(AppTypography.body)
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.xs)
                .background(AppTheme.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.pill, style: .continuous))
                .accessibilityLabel("Message input")

            Image(systemName: "arrow.up.circle.fill")
                .font(.system(size: AppSizes.iconLarge))
                .foregroundStyle(isSendDisabled ? AppTheme.textSecondary : AppTheme.primary)
                .accessibilityLabel("Send")
                .accessibilityHidden(true)
        }
    }
}

#Preview {
    ChatInputPlaceholder(text: .constant(""))
        .padding()
}
