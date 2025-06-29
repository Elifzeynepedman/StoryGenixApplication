//
//  RouterViewModifier.swift
//  StoryGenixApp
//
//  Created by Elif Edman on 29.06.2025.
//

import SwiftUI

struct RouterViewModifier: ViewModifier {
   @State private var router = Router()
    
    // Handles all navigation destinations in one place
    private func routeView(for route: Route) -> some View {
        Group {
            switch route {
            case .script(let topic):
                ScriptScreen(topic: topic)
            case .voice(let script):
                VoiceScreen(script: script)
            case .images(let script):
               ImageScreen(script: script)
            case .videopreview:
                VideoPreviewScreen()
            }
        }
        .environment(router)
    }

    func body(content: Content) -> some View {
        NavigationStack(path: $router.path) {
            content
                .environment(router)
                .navigationDestination(for: Route.self) { route in
                    routeView(for: route)
                }
        }
    }
}

extension View {
    func withRouter() -> some View {
        self.modifier(RouterViewModifier())
    }
}
