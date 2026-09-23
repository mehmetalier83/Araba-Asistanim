import Combine
import Foundation

/// Presentation state for the AI Assistant screen. Responses are canned mock
/// text keyed by suggested question — there is no real model or network call.
@MainActor
final class AIAssistantViewModel: ObservableObject {
    @Published private(set) var messages: [ChatMessage]
    @Published private(set) var isAssistantTyping = false

    let suggestedQuestions: [String]
    private let mockResponses: [String: String]

    /// Parameters default to `nil` and fall back to PreviewData inside the
    /// body — default-argument expressions run in a nonisolated context in
    /// Swift's concurrency model, even though this initializer is MainActor-isolated.
    init(
        messages: [ChatMessage]? = nil,
        suggestedQuestions: [String]? = nil,
        mockResponses: [String: String]? = nil
    ) {
        self.messages = messages ?? [PreviewData.initialAssistantMessage]
        self.suggestedQuestions = suggestedQuestions ?? PreviewData.suggestedQuestions
        self.mockResponses = mockResponses ?? PreviewData.mockAssistantResponses
    }

    func askSuggestedQuestion(_ question: String) {
        messages.append(ChatMessage(role: .user, text: question))

        let response = mockResponses[question] ?? "I don't have an answer for that yet."
        isAssistantTyping = true

        Task {
            try? await Task.sleep(for: .milliseconds(500))
            messages.append(ChatMessage(role: .assistant, text: response))
            isAssistantTyping = false
        }
    }
}
