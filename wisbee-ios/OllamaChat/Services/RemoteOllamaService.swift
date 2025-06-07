import Foundation

class RemoteOllamaService {
    private var baseURL: String = "http://localhost:11434"
    private let session = URLSession.shared
    
    func updateBaseURL(_ url: String) {
        baseURL = url
    }
    
    func checkConnection() async -> Bool {
        guard let url = URL(string: "\(baseURL)/api/tags") else { return false }
        
        do {
            let (_, response) = try await session.data(from: url)
            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            }
        } catch {
            print("Connection check failed: \(error)")
        }
        
        return false
    }
    
    func getAvailableModels() async -> [String]? {
        guard let url = URL(string: "\(baseURL)/api/tags") else { return nil }
        
        do {
            let (data, _) = try await session.data(from: url)
            let response = try JSONDecoder().decode(ModelsResponse.self, from: data)
            return response.models.map { $0.name }
        } catch {
            print("Failed to fetch models: \(error)")
            return nil
        }
    }
    
    func generate(prompt: String, model: String, stream: Bool = true) async throws -> String {
        guard let url = URL(string: "\(baseURL)/api/generate") else {
            throw OllamaError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = GenerateRequest(
            model: model,
            prompt: prompt,
            stream: false,  // For simplicity, not streaming in iOS app
            options: GenerateOptions(temperature: 0.7, num_predict: 500)
        )
        
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw OllamaError.requestFailed
        }
        
        let generateResponse = try JSONDecoder().decode(GenerateResponse.self, from: data)
        return generateResponse.response
    }
}

// MARK: - Models

struct ModelsResponse: Codable {
    let models: [Model]
    
    struct Model: Codable {
        let name: String
        let modified_at: String
        let size: Int
    }
}

struct GenerateRequest: Codable {
    let model: String
    let prompt: String
    let stream: Bool
    let options: GenerateOptions
}

struct GenerateOptions: Codable {
    let temperature: Double
    let num_predict: Int
}

struct GenerateResponse: Codable {
    let response: String
    let done: Bool
}

enum OllamaError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
}