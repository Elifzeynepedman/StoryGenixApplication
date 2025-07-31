//
//  AppSettingsScreen.swift
//  StoryGenix
//
//  Created by Elif Edman on 5.07.2025.
//

import SwiftUI

struct AppSettingsScreen: View {
    @Environment(Router.self) private var router
    @EnvironmentObject private var projectViewModel: ProjectsViewModel
    @State private var showResetConfirmation = false

    var body: some View {
        ZStack {
            // Background (same as Settings screen)
            Image("BackgroundImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    // Header
                    HStack {
                        Button(action: { router.path.removeLast() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            Text("Back")
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)

                    VStack(spacing: 4) {
                        Text("App Settings")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        Text("Manage storage and app info")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.bottom, 20)

                    // Storage Section
                    settingsSection(title: "STORAGE") {
                        settingsRow(icon: "trash.circle.fill", title: "Clear Cache") {
                            print("🧹 Clear Cache tapped")
                        }

                        settingsRow(icon:  "info.circle.fill",  title: "Reset Projects") {
                            showResetConfirmation = true
                        }
                    }

                    // Info Section
                    settingsSection(title: "INFO") {
                        settingsRowWithTrailing(icon: "info.circle.fill", title: "App Version") {
                            Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal)
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert("Reset All Projects?", isPresented: $showResetConfirmation) {
            Button("Delete All", role: .destructive) {
                projectViewModel.resetProjects()
            }
            Button("Cancel", role: .cancel) { }
        }
    }

    // MARK: - Reusable Components (Same as Settings Screen)

    private func settingsSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
                .padding(.horizontal)
            content()
        }
    }

    private func settingsRow(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(width: 30)

                Text(title)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))

                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private func settingsRowWithTrailing(icon: String, title: String, @ViewBuilder trailing: () -> some View) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.white)
                .frame(width: 30)

            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .medium))

            Spacer()
            trailing()
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    AppSettingsScreen()
        .environment(Router())
        .environmentObject(ProjectsViewModel())
}

