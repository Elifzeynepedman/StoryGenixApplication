//
//  AuthManager.swift
//  StoryGenix
//
//  Created by Elif Edman on 1.08.2025.
//

import FirebaseAuth

class AuthManager {
    static let shared = AuthManager()

    private init() {}

    func signInAnonymously(completion: @escaping (Result<User, Error>) -> Void) {
        if let user = Auth.auth().currentUser {
            completion(.success(user))
        } else {
            Auth.auth().signInAnonymously { authResult, error in
                if let error = error {
                    completion(.failure(error))
                } else if let user = authResult?.user {
                    completion(.success(user))
                }
            }
        }
    }

    func getIDToken(completion: @escaping (String?) -> Void) {
        Auth.auth().currentUser?.getIDToken { token, _ in
            completion(token)
        }
    }

    func refreshIDToken(completion: @escaping (String?) -> Void) {
        Auth.auth().currentUser?.getIDTokenForcingRefresh(true) { token, _ in
            completion(token)
        }
    }

    /// ✅ Add this method for upgrading anonymous accounts
    func linkAccount(with credential: AuthCredential, completion: @escaping (Result<User, Error>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "AuthManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return
        }

        currentUser.link(with: credential) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = authResult?.user {
                completion(.success(user))
            }
        }
    }
}
