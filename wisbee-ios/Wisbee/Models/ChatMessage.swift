import Foundation

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp = Date()
    
    init(content: String, isUser: Bool) {
        self.content = content
        self.isUser = isUser
    }
}