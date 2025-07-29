//
//  StoryGenixAppApp.swift
//  StoryGenixApp
//
//  Created by Elif Edman on 29.06.2025.
//

import SwiftUI
import Firebase


@main
struct StoryGenixAppApp: App {
    
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}

 
