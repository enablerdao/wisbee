import Foundation
import SpeziLLM
import SpeziLLMLocal

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isGenerating = false
    @Published var errorMessage: String?
    
    private var llmRunner: LLMRunner?
    private let modelURL = "https://huggingface.co/TheBloke/Qwen1.5-0.5B-Chat-GGUF/resolve/main/qwen1_5-0_5b-chat-q4_k_m.gguf"
    
    func initializeModel() {
        Task {
            do {
                // Initialize the local LLM
                let schema = LLMLocalSchema(
                    modelPath: URL(string: modelURL)!,
                    contextParameters: .init(
                        contextWindowSize: 2048,
                        batchSize: 512
                    ),
                    samplingParameters: .init(
                        temperature: 0.7,
                        topP: 0.9
                    )
                )
                
                llmRunner = LLMLocalRunner(schema: schema)
                
                // Add welcome message
                let welcomeMessage = ChatMessage(
                    content: "こんにちは！Wisbeeです。何かお手伝いできることはありますか？",
                    isUser: false
                )
                messages.append(welcomeMessage)
                
            } catch {
                errorMessage = "モデルの初期化に失敗しました: \(error.localizedDescription)"
                print("Failed to initialize model: \(error)")
            }
        }
    }
    
    func sendMessage(_ text: String) async {
        // Add user message
        let userMessage = ChatMessage(content: text, isUser: true)
        messages.append(userMessage)
        
        isGenerating = true
        errorMessage = nil
        
        do {
            // Build conversation context
            let context = buildContext()
            
            // Generate response
            var responseText = ""
            
            if let runner = llmRunner {
                for try await token in try runner.generate(prompt: context) {
                    responseText += token
                }
            } else {
                // Fallback to Ollama if available
                responseText = try await generateWithOllama(prompt: context)
            }
            
            // Add assistant message
            let assistantMessage = ChatMessage(
                content: responseText.trimmingCharacters(in: .whitespacesAndNewlines),
                isUser: false
            )
            messages.append(assistantMessage)
            
        } catch {
            errorMessage = "エラーが発生しました: \(error.localizedDescription)"
            let errorMsg = ChatMessage(
                content: "申し訳ございません。エラーが発生しました。",
                isUser: false
            )
            messages.append(errorMsg)
        }
        
        isGenerating = false
    }
    
    private func buildContext() -> String {
        let recentMessages = messages.suffix(10)
        let context = recentMessages.map { msg in
            msg.isUser ? "User: \(msg.content)" : "Assistant: \(msg.content)"
        }.joined(separator: "\n")
        
        return context + "\nAssistant:"
    }
    
    private func generateWithOllama(prompt: String) async throws -> String {
        // Try to connect to Mac's Ollama server
        guard let url = URL(string: "http://localhost:11434/api/generate") else {
            throw ChatError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = [
            "model": "jaahas/qwen3-abliterated:0.6b",
            "prompt": prompt,
            "stream": false,
            "options": [
                "temperature": 0.7,
                "num_predict": 200
            ]
        ] as [String : Any]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(OllamaResponse.self, from: data)
        
        return response.response
    }
}

enum ChatError: Error {
    case invalidURL
    case modelNotLoaded
}

struct OllamaResponse: Codable {
    let response: String
}