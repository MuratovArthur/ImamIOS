import Foundation

struct ChatMessage {
    let id: String
    let content: String
    let dataCreated: Date
    let sender: MessageSender
}

enum MessageSender {
    case user
    case gpt
}

extension ChatMessage {
    static let sampleMessages = [
        ChatMessage(id: UUID().uuidString, content: "Ассаламу Алейкум! Как я могу вам помочь?", dataCreated: Date(), sender: .gpt)
    ]
}



