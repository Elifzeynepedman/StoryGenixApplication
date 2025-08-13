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
    // ✅ Use @AppStorage for persistence of onboarding state
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var router = Router()
    @StateObject private var creditsVM = CreditsViewModel()
    @StateObject private var projectViewModel = ProjectsViewModel() // Inject ProjectsViewModel here

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if hasSeenOnboarding {
                    MainTabView()
                } else {
                    OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
                }
            }
            // ✅ Inject environment objects here so they are available to all views
            .environment(router)
            .environmentObject(creditsVM)
            .environmentObject(projectViewModel)
        }
    }
}
