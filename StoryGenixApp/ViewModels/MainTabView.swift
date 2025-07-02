//
//  MainTabView.swift
//  StoryGenix
//
//  Created by Elif Edman on 2.07.2025.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var router = Router()

    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            NavigationStack(path: $router.path) {
                ContentView()
                    .environment(router)
                    .navigationDestination(for: Route.self) { route in
                        routeView(for: route)
                            .environment(router) 
                    }
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)

            // Projects Tab
            NavigationStack {
                ProjectsScreen()
            }
            .tabItem {
                Label("Projects", systemImage: "folder.fill")
            }
            .tag(1)

            // Settings Tab
            NavigationStack {
                SettingsScreen()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(2)
        }
    }

    @ViewBuilder
    private func routeView(for route: Route) -> some View {
        switch route {
        case .home:
            EmptyView()
        case .script(let topic):
            ScriptScreen(topic: topic)
        case .voice(let script):
            VoiceScreen(script: script)
        case .images(let script):
            ImageScreen(script: script)
        case .videopreview(let script):
            VideoPreviewScreen(script: script)
        case .videocomplete:
            VideoCompleteScreen()
        }
    }
}
