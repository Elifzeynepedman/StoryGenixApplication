import Foundation

class ApiService {
    static let shared = ApiService()
    
    #if targetEnvironment(simulator)
    private let baseURL = "http://127.0.0.1:5001"
    #else
    private let baseURL = "http://192.168.1.247:5001" // ✅ Correct LAN IP
    #endif

    
    private init() {}
    
    // MARK: - Helper for Authenticated Requests
    private func authorizedRequest(for url: URL, method: String = "POST") async throws -> URLRequest {
        let token = try await withCheckedThrowingContinuation { continuation in
            AuthManager.shared.getIDToken { token in
                if let token = token {
                    continuation.resume(returning: token)
                } else {
                    continuation.resume(throwing: NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No Firebase token found"]))
                }
            }
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    // MARK: - Fetch Surprise Topic
    func fetchRandomTopic() async throws -> String {
        guard let url = URL(string: "\(baseURL)/api/script/create_random_topic") else {
            throw URLError(.badURL)
        }
        var request = try await authorizedRequest(for: url)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response, data: data, domain: "RandomTopicAPI")
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        return json?["topic"] as? String ?? "Unknown Topic"
    }
    
    // MARK: - Create Project
    func createProject(title: String, topic: String) async throws -> ProjectResponseModel {
        guard let url = URL(string: "\(baseURL)/api/projects") else { throw URLError(.badURL) }
        var request = try await authorizedRequest(for: url)
        let body = ["title": title, "topic": topic]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response, data: data, domain: "ProjectAPI")
        return try JSONDecoder().decode(ProjectResponseModel.self, from: data)
    }
    
    // MARK: - Generate Script
    func generateScriptForProject(projectId: String, topic: String) async throws -> ScriptResponseModel {
        guard let url = URL(string: "\(baseURL)/api/projects/\(projectId)/script") else { throw URLError(.badURL) }
        var request = try await authorizedRequest(for: url)
        let body = ["topic": topic]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response, data: data, domain: "ScriptAPI")
        return try JSONDecoder().decode(ScriptResponseModel.self, from: data)
    }
    
    // MARK: - Generate Images
    func generateImages(projectId: String, numImages: Int = 4, aspectRatio: String = "square") async throws -> ImageResponseModel {
        guard let url = URL(string: "\(baseURL)/api/scenes/generate-images") else { throw URLError(.badURL) }
        var request = try await authorizedRequest(for: url)
        let body = GenerateImagesRequest(projectId: projectId, numImages: numImages, aspectRatio: aspectRatio)
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response, data: data, domain: "ImageAPI")
        return try JSONDecoder().decode(ImageResponseModel.self, from: data)
    }
    
    // MARK: - Generate Voice
    func generateVoice(projectId: String, voiceId: String, script: String, sceneIndex: Int) async throws -> GenerateVoiceResponse {
        guard let url = URL(string: "\(baseURL)/api/audio/generate-voice") else { throw URLError(.badURL) }
        var request = try await authorizedRequest(for: url)
        
        let body: [String: Any] = [
            "projectId": projectId,
            "voiceId": voiceId,
            "script": script,
            "sceneIndex": sceneIndex
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response, data: data, domain: "VoiceAPI")
        return try JSONDecoder().decode(GenerateVoiceResponse.self, from: data)
    }
    
    // MARK: - Start Video Generation
    func startVideoGeneration(projectId: String, videoScenes: [[String: String]], audioFile: String, sceneAlignment: String) async throws -> VideoGenerationResponse {
        guard let url = URL(string: "\(baseURL)/api/video/\(projectId)/generate") else { throw URLError(.badURL) }
        var request = try await authorizedRequest(for: url)
        
        let body: [String: Any] = [
            "videoScenes": videoScenes,
            "audioFile": audioFile,
            "sceneAlignment": sceneAlignment
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response, data: data, domain: "VideoAPI")
        return try JSONDecoder().decode(VideoGenerationResponse.self, from: data)
    }
    
    // MARK: - Poll Video Status
    func getVideoStatus(projectId: String) async throws -> VideoStatusResponse {
        guard let url = URL(string: "\(baseURL)/api/video/\(projectId)/status") else { throw URLError(.badURL) }
        var request = try await authorizedRequest(for: url, method: "GET")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response, data: data, domain: "VideoStatusAPI")
        return try JSONDecoder().decode(VideoStatusResponse.self, from: data)
    }
    
    // MARK: - Validate Response
    private func validateResponse(_ response: URLResponse, data: Data, domain: String) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: domain, code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
        }
    }
    
    func generateImagesForScene(
        projectId: String,
        sceneIndex: Int,
        prompt: String,
        numImages: Int = 4,
        aspectRatio: String = "square"
    ) async throws -> [String] {
        guard let url = URL(string: "\(baseURL)/api/scenes/generate-images") else {
            throw URLError(.badURL)
        }
        
        var request = try await authorizedRequest(for: url)
        
        let body: [String: Any] = [
            "projectId": projectId,
            "sceneIndex": sceneIndex,
            "prompt": prompt,
            "numImages": numImages,
            "aspectRatio": aspectRatio
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response, data: data, domain: "ImageAPI")
        
        let json = try JSONDecoder().decode(ImageResponseModel.self, from: data)
        return json.images.first ?? []
    }


}

// MARK: - Models
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
