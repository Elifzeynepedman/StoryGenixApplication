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
    @StateObject private var projectViewModel = ProjectsViewModel()

    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            NavigationStack(path: $router.path) {
                ContentView()
                    .environment(router)
                    .environmentObject(projectViewModel)
                    .navigationDestination(for: Route.self) { route in
                        routeView(for: route)
                            .environment(router)
                            .environmentObject(projectViewModel)
                    }
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)

            // Projects Tab
            NavigationStack {
                ProjectsScreen()
                    .environmentObject(projectViewModel)
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
            ContentView()
        case .script(let topic):
            ScriptScreen(topic: topic)
        case .voice(let script, let topic):
            VoiceScreen(script: script, topic: topic)
        case .images(let script, let topic):
            ImageScreen(script: script, topic: topic)
        case .videopreview(let script, let topic):
            VideoPreviewScreen(script: script, topic: topic)
        case .videocomplete(let project):
            VideoCompleteScreen(project: project)
        }
    }
}
