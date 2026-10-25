import SwiftUI

/// The chat input bar: a text field plus a send button that's enabled once
/// there's something to send. (Name kept for history; it's fully wired now.)
struct ChatInputPlaceholder: View {
    @Binding var text: String
    var isSendDisabled: Bool = false
    var onSend: () -> Void = {}

    private var canSend: Bool {
        !isSendDisabled && !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            TextField("Aracın hakkında sor...", text: $text)
                .font(AppTypography.body)
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.xs)
                .background(AppTheme.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.pill, style: .continuous))
                .submitLabel(.send)
                .onSubmit { if canSend { onSend() } }
                .accessibilityLabel("Mesaj girişi")

            Button(action: onSend) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: AppSizes.iconLarge))
                    .foregroundStyle(canSend ? AppTheme.primary : AppTheme.textSecondary)
            }
            .disabled(!canSend)
            .accessibilityLabel("Gönder")
        }
    }
}

#Preview {
    ChatInputPlaceholder(text: .constant(""))
        .padding()
}
