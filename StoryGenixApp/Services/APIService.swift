import Foundation

class ApiService {
    static let shared = ApiService()

    #if targetEnvironment(simulator)
    private let baseURL = "http://127.0.0.1:5001"
    #else
    private let baseURL = "http://192.168.1.247:5001" // ✅ Your LAN IP for physical device
    #endif

    private init() {}

    // MARK: - Authenticated Request Helper
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

    // MARK: - Create Project
    func createProject(title: String, topic: String) async throws -> VideoProject {
        let url = URL(string: "\(baseURL)/api/projects")!
        var request = try await authorizedRequest(for: url)
        
        let body = ["title": title, "topic": topic]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(ProjectResponseModel.self, from: data)

        return VideoProject(
            id: UUID(),
            backendId: response._id,
            title: response.title,
            script: "",
            thumbnail: "defaultThumbnail",
            scenes: [],
            voiceId: nil,
            audioURL: nil,
            selectedImageIndices: [:],
            videoURL: nil,
            isCompleted: false,
            progressStep: ProgressStep(status: response.status)
        )
    }
    // MARK: - Fetch Random Topic
    func fetchRandomTopic() async throws -> String {
        guard let url = URL(string: "\(baseURL)/api/script/create_random_topic") else {
            throw URLError(.badURL)
        }

        var request = try await authorizedRequest(for: url, method: "GET")

        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response, data: data, domain: "RandomTopicAPI")

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        return json?["topic"] as? String ?? "Unknown Topic"
    }

    // MARK: - Generate Script
    func generateScriptForProject(projectId: String, topic: String) async throws -> ScriptResponseModel {
        let url = URL(string: "\(baseURL)/api/projects/\(projectId)/script")!
        var request = try await authorizedRequest(for: url)


        let body = [
            "topic": topic,
            "projectId": projectId
        ]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(ScriptResponseModel.self, from: data)
    }


    // MARK: - Generate Images
    func generateImages(projectId: String, numImages: Int = 4, aspectRatio: String = "square") async throws -> ImageResponseModel {
        let url = URL(string: "\(baseURL)/api/scenes/generate-images")!
        var request = try await authorizedRequest(for: url)
        let body = GenerateImagesRequest(projectId: projectId, numImages: numImages, aspectRatio: aspectRatio)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response, data: data, domain: "ImageAPI")
        return try JSONDecoder().decode(ImageResponseModel.self, from: data)
    }

    // MARK: - Generate Voice
    func generateVoice(projectId: String, voiceId: String, script: String, sceneIndex: Int) async throws -> GenerateVoiceResponse {
        let url = URL(string: "\(baseURL)/api/audio/generate-voice")!
        var request = try await authorizedRequest(for: url)
        let body = [
            "projectId": projectId,
            "voiceId": voiceId,
            "script": script,
            "sceneIndex": sceneIndex
        ] as [String: Any]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response, data: data, domain: "VoiceAPI")
        return try JSONDecoder().decode(GenerateVoiceResponse.self, from: data)
    }

    // MARK: - Start Video Generation
    func startVideoGeneration(projectId: String, videoScenes: [[String: String]], audioFile: String, sceneAlignment: String) async throws -> VideoGenerationResponse {
        let url = URL(string: "\(baseURL)/api/video/\(projectId)/generate")!
        var request = try await authorizedRequest(for: url)

        let body = [
            "videoScenes": videoScenes,
            "audioFile": audioFile,
            "sceneAlignment": sceneAlignment
        ] as [String: Any]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response, data: data, domain: "VideoAPI")
        return try JSONDecoder().decode(VideoGenerationResponse.self, from: data)
    }

    // MARK: - Get Final Video Status
    func getVideoStatus(projectId: String) async throws -> VideoStatusResponse {
        let url = URL(string: "\(baseURL)/api/video/\(projectId)/status")!
        var request = try await authorizedRequest(for: url, method: "GET")

        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response, data: data, domain: "VideoStatusAPI")
        return try JSONDecoder().decode(VideoStatusResponse.self, from: data)
    }

    // MARK: - Scene-specific Image Generation
    func generateImagesForScene(projectId: String, sceneIndex: Int, prompt: String, numImages: Int = 4, aspectRatio: String = "square") async throws -> [String] {
        let url = URL(string: "\(baseURL)/api/scenes/generate-images")!
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
        try validateResponse(response, data: data, domain: "ImageSceneAPI")

        let json = try JSONDecoder().decode(ImageResponseModel.self, from: data)
        return json.images.first ?? []
    }

    // MARK: - Response Validator
    private func validateResponse(_ response: URLResponse, data: Data, domain: String) throws {
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        guard (200...299).contains(http.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: domain, code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
        }
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
