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
            Image("BackgroundImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 24) {
                HStack {
                    Button("Back") {
                        router.path.removeLast()
                    }
                    .foregroundColor(.white.opacity(0.7))
                    Spacer()
                }
                .padding(.horizontal)

                Text("VidGenius")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)

                Text("App Settings")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

                appSettingButton("Clear Cache", action:  {
                    print("🧹 Clear Cache tapped")
                    // Add cache clearing logic if needed
                })

                appSettingButton("Reset Projects", action:  {
                    showResetConfirmation = true
                })

                appSettingButton("App Version", trailing: {
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                        .foregroundColor(.gray)
                }, isDisabled: true)

                Spacer()
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .alert("Reset All Projects?", isPresented: $showResetConfirmation) {
            Button("Delete All", role: .destructive) {
                projectViewModel.resetProjects()
            }
            Button("Cancel", role: .cancel) { }
        }
    }

    @ViewBuilder
    private func appSettingButton(
        _ title: String,
        trailing: (() -> Text)? = nil,
        isDisabled: Bool = false,
        action: (() -> Void)? = nil
    ) -> some View {
        Button(action: { action?() }) {
            HStack {
                Text(title)
                    .foregroundColor(.white)
                    .fontWeight(.medium)
                Spacer()
                trailing?()
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .disabled(isDisabled)
    }
}

#Preview {
    AppSettingsScreen()
        .environment(Router())
        .environmentObject(ProjectsViewModel())
}
