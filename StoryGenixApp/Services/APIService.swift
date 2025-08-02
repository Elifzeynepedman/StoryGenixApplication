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
    
    // ✅ Generate Script (Legacy endpoint)
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
    
    // ✅ Generate Script for Project
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
    
    func generateVoice(projectId: String, voiceId: String, script: String, sceneIndex: Int) async throws -> GenerateVoiceResponse {
        let endpoint = URL(string: "\(baseURL)/api/audio/generate-voice")!
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "projectId": projectId,
            "userId": "test-user",
            "voiceId": voiceId,
            "script": script,
            "sceneIndex": sceneIndex
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(GenerateVoiceResponse.self, from: data)
    }

    
    // ✅ Start Video Generation
    func startVideoGeneration(projectId: String, videoScenes: [[String: String]], audioFile: String, sceneAlignment: String) async throws -> VideoGenerationResponse {
        guard let url = URL(string: "\(baseURL)/api/video/\(projectId)/generate") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 120
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "videoScenes": videoScenes,
            "audioFile": audioFile,
            "sceneAlignment": sceneAlignment
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "VideoAPI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
        }
        
        return try JSONDecoder().decode(VideoGenerationResponse.self, from: data)
    }

    // ✅ Poll Video Status
    func getVideoStatus(projectId: String) async throws -> VideoStatusResponse {
        guard let url = URL(string: "\(baseURL)/api/video/\(projectId)/status") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 60
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "VideoStatusAPI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
        }
        
        return try JSONDecoder().decode(VideoStatusResponse.self, from: data)
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

struct VoiceResponseModel: Codable {
    let audio_url: String
    let lastStep: String
}

struct VideoGenerationResponse: Codable {
    let projectId: String
    let jobId: String
    let status: String
}

struct VideoStatusResponse: Codable {
    let projectId: String
    let status: String
    let finalVideoUrl: String?
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

struct GenerateVoiceResponse: Codable {
    let audio_url: String
    let lastStep: String
}
