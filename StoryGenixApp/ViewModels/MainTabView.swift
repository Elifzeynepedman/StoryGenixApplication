import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var router = Router()
    @StateObject private var projectViewModel = ProjectsViewModel()

    init() {
        let bg = UIColor(named: "BackgroundColor") ?? UIColor(red: 0.09, green: 0.03, blue: 0.15, alpha: 1) // #180826
        let accent = UIColor(named: "AccentPrimary") ?? UIColor(red: 0.75, green: 0.40, blue: 1.00, alpha: 1) // magenta glow
        let muted = UIColor(named: "AccentMuted") ?? UIColor(red: 0.63, green: 0.63, blue: 0.63, alpha: 1) // Cool Gray

        // Tab bar appearance
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = bg
        tabAppearance.stackedLayoutAppearance.normal.iconColor = muted
        tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: muted]
        tabAppearance.stackedLayoutAppearance.selected.iconColor = accent
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: accent]
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance

        // Navigation bar appearance
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = bg
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        UINavigationBar.appearance().tintColor = accent
    }

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
            NavigationStack(path: $router.path) {
                SettingsScreen()
                    .environment(router)
                    .environmentObject(projectViewModel)
                    .navigationDestination(for: Route.self) { route in
                        routeView(for: route)
                            .environment(router)
                            .environmentObject(projectViewModel)
                    }
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(2)
        }
        .tint(Color("AccentPrimary")) // selected icon & highlight
        .background(Color("BackgroundColor").ignoresSafeArea())
        .onChange(of: selectedTab) {
            if selectedTab == 1 {
                router.goToHome()
            }
        }
    }

    @ViewBuilder
    private func routeView(for route: Route) -> some View {
        switch route {
        case .home:
            ContentView()
        case .script(let project):
            ScriptScreen(project: project)
        case .voice(let project):
            VoiceScreen(project: project)
        case .images(let project):
            ImageScreen(project: project)
        case .videopreview(let project):
            VideoPreviewScreen(project: project)
        case .videocomplete(let project):
            VideoCompleteScreen(project: project)
        case .appSettings:
            AppSettingsScreen()
        case .contact:
            ContactScreen()
        }
    }
}
