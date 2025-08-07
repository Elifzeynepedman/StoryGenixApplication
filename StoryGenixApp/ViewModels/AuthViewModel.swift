//
//  AuthViewModel.swift
//  StoryGenix
//
//  Created by Elif Edman on 2.08.2025.
//

import FirebaseAuth
import Combine

class AuthViewModel: ObservableObject {
    @Published var user: User?
    private var handle: AuthStateDidChangeListenerHandle?
    
    init() {
        self.user = Auth.auth().currentUser
        listenForAuthChanges()
    }
    
    private func listenForAuthChanges() {
        handle = Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
        }
    }
    
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("❌ Sign-out failed: \(error.localizedDescription)")
        }
    }
}
