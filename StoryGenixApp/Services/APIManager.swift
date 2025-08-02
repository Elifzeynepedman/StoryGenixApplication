//
//  APIManager.swift
//  StoryGenix
//
//  Created by Elif Edman on 1.08.2025.
//

import Foundation

class APIManager {
    static let shared = APIManager()
    
    // ✅ Base URL for backend
    #if targetEnvironment(simulator)
    private let baseURL = "http://127.0.0.1:5001" // Simulator can use localhost
    #else
    private let baseURL = "http://192.168.1.247:5001" // Real device uses LAN IP
    #endif

    func syncUser(firebaseUid: String, email: String?, username: String?) {
        AuthManager.shared.getIDToken { token in
            guard let token = token else { return }
            
            guard let url = URL(string: "\(self.baseURL)/api/auth/sync") else {
                print("❌ Invalid URL")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            let body: [String: Any] = [
                "firebaseUid": firebaseUid,
                "email": email ?? "",
                "username": username ?? "anonymous"
            ]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Sync error: \(error.localizedDescription)")
                } else {
                    print("✅ User synced successfully.")
                }
            }.resume()
        }
    }
}
