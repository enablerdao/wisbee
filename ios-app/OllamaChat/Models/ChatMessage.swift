import Foundation

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date = Date()
    let model: String?
    
    init(content: String, isUser: Bool, model: String? = nil) {
        self.content = content
        self.isUser = isUser
        self.model = model
    }
}