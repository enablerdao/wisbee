import Foundation
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var selectedModel = "local"
    @Published var availableModels = ["local", "mac-remote"]
    @Published var connectionStatus: ConnectionStatus = .disconnected
    
    private let localModelManager = LocalModelManager()
    private let remoteOllamaService = RemoteOllamaService()
    private var cancellables = Set<AnyCancellable>()
    
    enum ConnectionStatus {
        case disconnected
        case connecting
        case connected
        case error(String)
    }
    
    init() {
        setupLocalModel()
        checkMacConnection()
    }
    
    private func setupLocalModel() {
        Task {
            do {
                try await localModelManager.loadModel()
                print("Local model loaded successfully")
            } catch {
                print("Failed to load local model: \(error)")
            }
        }
    }
    
    private func checkMacConnection() {
        Task {
            if await remoteOllamaService.checkConnection() {
                connectionStatus = .connected
                // Load available models from Mac
                if let models = await remoteOllamaService.getAvailableModels() {
                    availableModels = ["local"] + models
                }
            }
        }
    }
    
    func sendMessage(_ text: String) async {
        let userMessage = ChatMessage(content: text, isUser: true)
        messages.append(userMessage)
        
        isLoading = true
        
        do {
            let response: String
            
            if selectedModel == "local" {
                // Use local qwen3-abliterated:0.6b
                response = try await localModelManager.generate(prompt: buildPrompt())
            } else {
                // Use remote Ollama on Mac
                response = try await remoteOllamaService.generate(
                    prompt: buildPrompt(),
                    model: selectedModel
                )
            }
            
            let assistantMessage = ChatMessage(
                content: response,
                isUser: false,
                model: selectedModel
            )
            messages.append(assistantMessage)
            
        } catch {
            let errorMessage = ChatMessage(
                content: "Error: \(error.localizedDescription)",
                isUser: false,
                model: selectedModel
            )
            messages.append(errorMessage)
        }
        
        isLoading = false
    }
    
    private func buildPrompt() -> String {
        // Build conversation context
        let context = messages.suffix(10).map { message in
            if message.isUser {
                return "User: \(message.content)"
            } else {
                return "Assistant: \(message.content)"
            }
        }.joined(separator: "\n\n")
        
        return context
    }
    
    func clearChat() {
        messages.removeAll()
    }
}