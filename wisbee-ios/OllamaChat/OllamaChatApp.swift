import SwiftUI

@main
struct OllamaChatApp: App {
    @StateObject private var chatViewModel = ChatViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(chatViewModel)
        }
    }
}