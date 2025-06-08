import SwiftUI

@main
struct WisbeeApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(.dark)
        }
    }
}

class AppState: ObservableObject {
    @Published var isModelLoaded = false
    @Published var currentModel = "qwen3-abliterated-0.6b"
    @Published var connectionMode: ConnectionMode = .local
    
    enum ConnectionMode {
        case local
        case remote
    }
}