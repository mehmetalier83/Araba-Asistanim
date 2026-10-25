import Foundation

/// A single message in the AI Assistant conversation.
struct ChatMessage: Identifiable, Hashable {
    let id: UUID
    let role: ChatRole
    let text: String
    let date: Date

    init(id: UUID = UUID(), role: ChatRole, text: String, date: Date = .now) {
        self.id = id
        self.role = role
        self.text = text
        self.date = date
    }
}

enum ChatRole: Hashable {
    case user
    case assistant
}
