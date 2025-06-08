import Foundation
import SpeziLLM
import SpeziLLMLocal

protocol LLMRunner {
    func generate(prompt: String) throws -> AsyncThrowingStream<String, Error>
}

class LLMLocalRunner: LLMRunner {
    private let llm: LLMLocal
    
    init(schema: LLMLocalSchema) {
        self.llm = LLMLocal(schema: schema)
    }
    
    func generate(prompt: String) throws -> AsyncThrowingStream<String, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    await llm.generate(prompt: prompt) { token in
                        continuation.yield(token)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}

// Alternative implementation using llama.cpp directly
class LlamaCppRunner: LLMRunner {
    private var modelPath: String
    private var context: OpaquePointer?
    
    init(modelPath: String) throws {
        self.modelPath = modelPath
        // Initialize llama.cpp context here
        // This would require bridging to C/C++ code
    }
    
    func generate(prompt: String) throws -> AsyncThrowingStream<String, Error> {
        // Implementation for direct llama.cpp usage
        return AsyncThrowingStream { continuation in
            // Generate tokens using llama.cpp
            continuation.finish()
        }
    }
    
    deinit {
        // Clean up llama.cpp context
    }
}