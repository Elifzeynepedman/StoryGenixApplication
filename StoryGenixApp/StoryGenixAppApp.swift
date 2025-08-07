//
//  StoryGenixAppApp.swift
//  StoryGenixApp
//
//  Created by Elif Edman on 29.06.2025.
//

import SwiftUI
import Firebase
import GoogleSignIn

@main
struct StoryGenixAppApp: App {
    @State private var hasSeenOnboarding = false
    @State private var router = Router()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                MainTabView()
                    .environment(router)
            } else {
                OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
                    .environment(router)
            }
        }
    }}
