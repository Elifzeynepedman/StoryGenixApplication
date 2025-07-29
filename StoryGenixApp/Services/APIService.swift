//
//  APIService.swift
//  StoryGenix
//
//  Created by Elif Edman on 29.07.2025.
//

import Foundation

class ApiService {
    static let shared = ApiService()
    private let baseURL = "http://192.168.1.247:5001/api" // ✅ Adjust for real IP

    private init() {}

    // ✅ Get Random Topic
    func getRandomTopic() async throws -> String {
        guard let url = URL(string: "\(baseURL)/script/create_random_topic") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(RandomTopicResponse.self, from: data)
        return response.topic
    }

    // ✅ Generate Script
    func generateScript(topic: String, projectId: String) async throws -> CreateScriptResponse {
        guard let url = URL(string: "\(baseURL)/script/create_script") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["topic": topic, "projectId": projectId]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(CreateScriptResponse.self, from: data)
    }
}

struct RandomTopicResponse: Codable {
    let topic: String
}

struct SceneResponse: Codable {
    let index: Int
    let text: String
}

struct CreateScriptResponse: Codable {
    let projectId: String
    let script: String
    let scenes: [SceneResponse]
    let message: String
}
