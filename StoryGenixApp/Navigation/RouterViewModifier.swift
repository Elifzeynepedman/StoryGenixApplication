//
//  RouterViewModifier.swift
//  StoryGenixApp
//
//  Created by Elif Edman on 29.06.2025.
//

import SwiftUI
import Foundation

struct RouterViewModifier: ViewModifier {
   @State private var router = Router()
    @State private var selectedTab = 0

    func body(content: Content) -> some View {
        NavigationStack(path: $router.path) {
            ZStack {
                if router.path.isEmpty {
                    TabView(selection: $selectedTab) {
                        tabContent(for: 0)
                            .tag(0)
                            .tabItem {
                                Label("Home", systemImage: "house.fill")
                            }

                        tabContent(for: 1)
                            .tag(1)
                            .tabItem {
                                Label("Projects", systemImage: "folder.fill")
                            }

                        tabContent(for: 2)
                            .tag(2)
                            .tabItem {
                                Label("Settings", systemImage: "gear")
                            }
                    }
                } else {
                    content
                }
            }
            .environment(router)
            .navigationDestination(for: Route.self) { route in
                routeView(for: route)
            }
        }
    }
    
    @ViewBuilder
    private func tabContent(for index: Int) -> some View {
        switch index {
        case 0:
            ContentView()
        case 1:
            ProjectsScreen()
        case 2:
            SettingsScreen()
        default:
            EmptyView()
        }
    }
    
    // Handles all navigation destinations in one place
    private func routeView(for route: Route) -> some View {
        Group {
            switch route {
            case .home:
                ContentView()
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
        .environment(router)
    }

}

extension View {
    func withRouter() -> some View {
        self.modifier(RouterViewModifier())
    }
}
