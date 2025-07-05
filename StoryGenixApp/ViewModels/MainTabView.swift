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
            NavigationStack(path: $router.path) {
                ProjectsScreen()
                    .environment(router)
                    .environmentObject(projectViewModel)
                    .navigationDestination(for: Route.self) { route in
                        routeView(for: route)
                            .environment(router)
                            .environmentObject(projectViewModel)
                    }
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
        // ✅ Reset navigation path when switching to Projects tab
        .onChange(of: selectedTab) { tab in
            if tab == 1 {
                router.goToHome()
            }
        }
    }

    @ViewBuilder
    private func routeView(for route: Route) -> some View {
        switch route {
        case .home:
            ContentView()
        case .script(let topic):
            ScriptScreen(topic: topic)
        case .voice(let project):
            VoiceScreen(project: project)
        case .images(let project):
            ImageScreen(project: project)
        case .videopreview(let project):
            VideoPreviewScreen(project: project)
        case .videocomplete(let project):
            VideoCompleteScreen(project: project)
        }
    }
}
