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
                .submitLabel(.send)
                .onSubmit { if canSend { onSend() } }
                .accessibilityLabel("Mesaj girişi")

            Button(action: onSend) {
                Image(systemName: "arrow.up")
                    .font(.system(size: AppSizes.iconSmall, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(
                        canSend ? AnyShapeStyle(LinearGradient.mascot()) : AnyShapeStyle(AppTheme.textTertiary),
                        in: Circle()
                    )
            }
            .disabled(!canSend)
            .accessibilityLabel("Gönder")
        }
        .padding(.leading, AppSpacing.md)
        .padding(.trailing, 6)
        .padding(.vertical, 6)
        .appCard(cornerRadius: AppCornerRadius.pill)
    }
}

#Preview {
    ChatInputPlaceholder(text: .constant(""))
        .padding()
}
