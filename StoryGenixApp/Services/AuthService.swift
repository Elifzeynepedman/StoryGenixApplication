//
//  AuthService.swift
//  StoryGenix
//
//  Created by Elif Edman on 29.07.2025.
//

import Foundation

class AuthService {
    static let shared = AuthService()
    private let baseURL = "http://192.168.1.247:5001/api" // ✅ Use your Mac IP for real device

    private init() {}

    struct AuthResponse: Codable {
        let token: String
    }

    func login(email: String, password: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["email": email, "password": password]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(AuthResponse.self, from: data)

        // ✅ Save token for future requests
        UserDefaults.standard.set(response.token, forKey: "authToken")

        return response.token
    }
}
