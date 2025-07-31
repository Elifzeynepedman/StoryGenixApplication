import Foundation

class ApiService {
    static let shared = ApiService()
    
    #if targetEnvironment(simulator)
    private let baseURL = "http://127.0.0.1:5001" // For Simulator
    #else
    private let baseURL = "http://192.168.x.x:5001" // Replace with your LAN IP
    #endif
    
    private init() {}
    
    // ✅ Create Project
    func createProject(title: String, topic: String) async throws -> ProjectResponseModel {
        guard let url = URL(string: "\(baseURL)/api/projects") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["title": title, "topic": topic]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "ProjectAPI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }
        
        return try JSONDecoder().decode(ProjectResponseModel.self, from: data)
    }
    
    // ✅ Generate Script
    func generateScript(topic: String, projectId: String) async throws -> ScriptResponseModel {
        guard let url = URL(string: "\(baseURL)/api/script/create_script") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["topic": topic, "projectId": projectId]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "ScriptAPI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
        }
        
        return try JSONDecoder().decode(ScriptResponseModel.self, from: data)
    }
    
    
    // ✅ Generate Script and Save Scenes for Project
    func generateScriptForProject(projectId: String, topic: String) async throws -> ScriptResponseModel {
        guard let url = URL(string: "\(baseURL)/api/projects/\(projectId)/script") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["topic": topic]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "ScriptAPI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
        }
        
        return try JSONDecoder().decode(ScriptResponseModel.self, from: data)
    }

    // ✅ Generate Images
    func generateImages(projectId: String, numImages: Int = 4, aspectRatio: String = "square") async throws -> ImageResponseModel {
        guard let url = URL(string: "\(baseURL)/api/scenes/generate-images") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 120
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = GenerateImagesRequest(projectId: projectId, numImages: numImages, aspectRatio: aspectRatio)
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "ImageAPI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
        }
        
        return try JSONDecoder().decode(ImageResponseModel.self, from: data)
    }
}

// ✅ Models
struct ProjectResponseModel: Codable {
    let _id: String
    let title: String
    let status: String
}
struct ScriptResponseModel: Codable {
    let projectId: String?
    let script: String
    let scenes: [SceneResponse]
    let message: String?
}

struct SceneResponse: Codable {
    let index: Int
    let text: String
    let imagePrompt: String
    let klingPrompt: String
}


struct ImageResponseModel: Codable {
    let projectId: String
    let images: [[String]]
    let lastStep: String
    let coverImage: String?
}

struct GenerateImagesRequest: Codable {
    let projectId: String
    let numImages: Int
    let aspectRatio: String
}
