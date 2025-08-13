import Foundation

// MARK: - ApiService

final class ApiService {
    static let shared = ApiService()

    #if targetEnvironment(simulator)
    let baseURL = "http://127.0.0.1:5001"
    #else
    let baseURL = "http://192.168.1.247:5001" // LAN IP for device
    #endif

    private init() {
        // You can tweak session config here if needed
    }

    // MARK: - Types

    enum HTTPMethod: String { case GET, POST }

    struct APIError: LocalizedError {
        let status: Int
        let message: String
        var errorDescription: String? { message }
    }

    // MARK: - URLSession

    private lazy var session: URLSession = {
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest = 30
        cfg.timeoutIntervalForResource = 60
        return URLSession(configuration: cfg)
    }()

    // MARK: - Authenticated Request Helper

    private func authorizedRequest(for url: URL, method: HTTPMethod = .POST) async throws -> URLRequest {
        let token = try await withCheckedThrowingContinuation { cont in
            AuthManager.shared.getIDToken { token in
                if let token { cont.resume(returning: token) }
                else {
                    cont.resume(throwing: APIError(status: 401, message: "No Firebase token found"))
                }
            }
        }

        var req = URLRequest(url: url)
        req.httpMethod = method.rawValue
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return req
    }

    // MARK: - Single executor

    private func send<T: Decodable, B: Encodable>(
        _ path: String,
        method: HTTPMethod = .POST,
        body: B? = nil,
        domain: String
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw APIError(status: -1, message: "Bad URL: \(path)")
        }
        var req = try await authorizedRequest(for: url, method: method)
        if let body {
            req.httpBody = try JSONEncoder().encode(body)
        }

        let (data, resp) = try await session.data(for: req)
        try validateResponse(resp, data: data, domain: domain)
        return try JSONDecoder().decode(T.self, from: data)
    }

    private func sendVoid<B: Encodable>(
        _ path: String,
        method: HTTPMethod = .POST,
        body: B? = nil,
        domain: String
    ) async throws {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw APIError(status: -1, message: "Bad URL: \(path)")
        }
        var req = try await authorizedRequest(for: url, method: method)
        if let body {
            req.httpBody = try JSONEncoder().encode(body)
        }
        let (data, resp) = try await session.data(for: req)
        try validateResponse(resp, data: data, domain: domain)
    }

    // MARK: - Response Validator

    private func validateResponse(_ response: URLResponse, data: Data, domain: String) throws {
        guard let http = response as? HTTPURLResponse else {
            throw APIError(status: -1, message: "[\(domain)] Invalid server response")
        }
        guard (200...299).contains(http.statusCode) else {
            let server = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError(status: http.statusCode, message: "[\(domain)] \(server)")
        }
    }

    @discardableResult
    func makeAuthorizedRequest(_ path: String,
                               method: String = "POST",
                               body: Data? = nil) async throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw APIError(status: -1, message: "Bad URL: \(path)")
        }
        let httpMethod = HTTPMethod(rawValue: method.uppercased()) ?? .POST
        var req = try await authorizedRequest(for: url, method: httpMethod)
        if let body { req.httpBody = body }
        return req
    }
    // MARK: - Public API

    // Create Project
    func createProject(title: String, topic: String) async throws -> VideoProject {
        let body = ["title": title, "topic": topic]
        let res: ProjectResponseModel = try await send(
            "/api/projects",
            body: body,
            domain: "CreateProjectAPI"
        )
        return VideoProject(
            id: UUID(),
            backendId: res._id,
            title: res.title,
            script: "",
            thumbnail: "defaultThumbnail",
            scenes: [],
            voiceId: nil,
            audioURL: nil,
            selectedImageIndices: [:],
            videoURL: nil,
            isCompleted: false,
            progressStep: ProgressStep(status: res.status)
        )
    }

    // Random Topic
    func fetchRandomTopic() async throws -> String {
        // Your router allows GET for random_topic
        struct Empty: Encodable {}
        let url = URL(string: "\(baseURL)/api/script/create_random_topic")!
        var req = try await authorizedRequest(for: url, method: .GET)
        let (data, resp) = try await session.data(for: req)
        try validateResponse(resp, data: data, domain: "RandomTopicAPI")
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        return json?["topic"] as? String ?? "Unknown Topic"
    }

    // 🔹 Generate Script from Topic (Auto-Generated mode)
    func createScriptFromTopic(projectId: String, topic: String) async throws -> ScriptResponseModel {
        let body = ["topic": topic, "projectId": projectId]
        return try await send("/api/script/create_script",
                              body: body,
                              domain: "TopicScriptAPI")
    }

    // ⛔️ Deprecated alias (kept for callers still using the old name)
    func generateScriptForProject(projectId: String, topic: String) async throws -> ScriptResponseModel {
        try await createScriptFromTopic(projectId: projectId, topic: topic)
    }

    // 🔹 Create Script from *Custom* text (Write My Own)
    func createCustomScript(projectId: String, scriptText: String) async throws -> ScriptResponseModel {
        let req = CreateCustomScriptRequest(projectId: projectId, scriptText: scriptText)
        return try await send("/api/script/create_custom_script",
                              body: req,
                              domain: "CustomScriptAPI")
    }

    // Generate all images
    func generateImages(projectId: String, numImages: Int = 4, aspectRatio: String = "square") async throws -> ImageResponseModel {
        let body = GenerateImagesRequest(projectId: projectId, numImages: numImages, aspectRatio: aspectRatio)
        return try await send("/api/scenes/generate-images",
                              body: body,
                              domain: "ImageAPI")
    }

    // Generate images for a single scene by prompt
    func generateImagesForScene(
        projectId: String,
        sceneIndex: Int,
        prompt: String,
        numImages: Int = 4,
        aspectRatio: String = "square"
    ) async throws -> [String] {
        let body: [String: Any] = [
            "projectId": projectId,
            "sceneIndex": sceneIndex,
            "prompt": prompt,
            "numImages": numImages,
            "aspectRatio": aspectRatio
        ]
        // Using manual request here due to heterogeneous body type
        let url = URL(string: "\(baseURL)/api/scenes/generate-scene")!
        var req = try await authorizedRequest(for: url, method: .POST)
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, resp) = try await session.data(for: req)
        try validateResponse(resp, data: data, domain: "ImageSceneAPI")

        let result = try JSONDecoder().decode(ImageSceneResponse.self, from: data)
        // Server returns relative paths; front-end expects absolute
        return result.images.map { "\(baseURL)\($0)" }
    }

    // Generate Voice
    func generateVoice(projectId: String, voiceId: String, script: String, sceneIndex: Int) async throws -> GenerateVoiceResponse {
        let body = [
            "projectId": projectId,
            "voiceId": voiceId,
            "script": script,
            "sceneIndex": sceneIndex
        ] as [String: Any]

        let url = URL(string: "\(baseURL)/api/audio/generate-voice")!
        var req = try await authorizedRequest(for: url, method: .POST)
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, resp) = try await session.data(for: req)
        try validateResponse(resp, data: data, domain: "VoiceAPI")
        return try JSONDecoder().decode(GenerateVoiceResponse.self, from: data)
    }

    // Start Video Generation
    func startVideoGeneration(projectId: String, videoScenes: [[String: String]], audioFile: String, sceneAlignment: String) async throws -> VideoGenerationResponse {
        let body = [
            "videoScenes": videoScenes,
            "audioFile": audioFile,
            "sceneAlignment": sceneAlignment
        ] as [String: Any]
        let url = URL(string: "\(baseURL)/api/video/\(projectId)/generate")!
        var req = try await authorizedRequest(for: url, method: .POST)
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, resp) = try await session.data(for: req)
        try validateResponse(resp, data: data, domain: "VideoAPI")
        return try JSONDecoder().decode(VideoGenerationResponse.self, from: data)
    }

    // Poll Video Status
    func getVideoStatus(projectId: String) async throws -> VideoStatusResponse {
        let url = URL(string: "\(baseURL)/api/video/\(projectId)/status")!
        var req = try await authorizedRequest(for: url, method: .GET)
        let (data, resp) = try await session.data(for: req)
        try validateResponse(resp, data: data, domain: "VideoStatusAPI")
        return try JSONDecoder().decode(VideoStatusResponse.self, from: data)
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

struct ImageSceneResponse: Codable {
    let success: Bool
    let projectId: String
    let sceneIndex: Int
    let images: [String]
}

private struct CreateCustomScriptRequest: Codable {
    let projectId: String
    let scriptText: String
}
