import SwiftUI

struct AIAssistantView: View {
    @StateObject private var viewModel = AIAssistantViewModel()
    @State private var draftText = ""
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: AppSpacing.md) {
                            header

                            VStack(spacing: AppSpacing.xs) {
                                ForEach(viewModel.messages) { message in
                                    ChatMessageBubble(message: message)
                                        .id(message.id)
                                }

                                if viewModel.isAssistantTyping {
                                    HStack {
                                        ProgressView()
                                        Text("Thinking…")
                                            .font(AppTypography.caption)
                                            .foregroundStyle(AppTheme.textSecondary)
                                        Spacer()
                                    }
                                }
                            }

                            if viewModel.messages.count <= 1 {
                                suggestedQuestions
                            }

                            disclaimer
                        }
                        .padding(AppSpacing.md)
                    }
                    .onChange(of: viewModel.messages.count) {
                        guard let lastID = viewModel.messages.last?.id else { return }
                        withAnimation(reduceMotion ? nil : AppAnimation.standard) {
                            proxy.scrollTo(lastID, anchor: .bottom)
                        }
                    }
                }

                Divider()

                ChatInputPlaceholder(text: $draftText)
                    .padding(AppSpacing.md)
            }
            .background(AppTheme.background)
            .navigationTitle("AI Vehicle Assistant")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var header: some View {
        Text("Ask questions about your vehicle.")
            .font(AppTypography.subheadline)
            .foregroundStyle(AppTheme.textSecondary)
    }

    private var suggestedQuestions: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Try asking")
                .font(AppTypography.caption)
                .foregroundStyle(AppTheme.textSecondary)

            ForEach(viewModel.suggestedQuestions, id: \.self) { question in
                SuggestedQuestionButton(question: question) {
                    viewModel.askSuggestedQuestion(question)
                }
            }
        }
    }

    private var disclaimer: some View {
        Text(PreviewData.aiDisclaimer)
            .font(AppTypography.caption)
            .foregroundStyle(AppTheme.textSecondary)
            .multilineTextAlignment(.leading)
            .padding(.top, AppSpacing.xs)
    }
}

#Preview {
    AIAssistantView()
}

#Preview("Dark") {
    AIAssistantView()
        .preferredColorScheme(.dark)
}
