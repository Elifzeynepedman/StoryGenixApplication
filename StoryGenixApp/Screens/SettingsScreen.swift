//
//  SettingsScreen.swift
//  StoryGenix
//
//  Created by Elif Edman on 2.07.2025.
//


import SwiftUI

struct SettingsScreen: View {
    @Environment(Router.self) private var router
    @State private var userId: String = "4324234"
    @State private var showBugModal = false
    @State private var showFeedbackModal = false

    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("StoryGenix")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)

                Text("Settings")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

                // Subscription
                settingsButton(title: "Subscription", trailing: {
                    AnyView(
                        Text("Pro")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(LinearGradient(colors: [.blue, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .clipShape(Capsule())
                            .foregroundColor(.white)
                    )
                })

                // App Settings
                settingsButton(title: "App Settings") {
                    router.goToAppSettings()
                }

                // Contact Us
                settingsButton(title: "Contact Us") {
                    router.goToContact()
                }

                // User ID
                settingsButton(title: "User ID", trailing: {
                    AnyView(Text(userId).foregroundColor(.gray))
                }, isDisabled: true)

                // Feedback
                settingsButton(title: "Improvements") {
                    showFeedbackModal = true
                }

                // Bug Report
                settingsButton(title: "Report a Bug") {
                    showBugModal = true
                }

                Spacer()
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showBugModal) {
            FeedbackModalView(
                title: "Report a Bug",
                placeholder: "Brief description of the bug",
                emoji: "🐞",
                onSubmit: { message in submitBugReport(message) },
                isPresented: $showBugModal
            )
        }
        .sheet(isPresented: $showFeedbackModal) {
            FeedbackModalView(
                title: "Improvements",
                placeholder: "How can we improve?",
                emoji: "💡",
                onSubmit: { message in submitFeedback(message) },
                isPresented: $showFeedbackModal
            )
        }
    }

    func submitBugReport(_ message: String) {
        print("📮 Bug submitted: \(message)")
    }

    func submitFeedback(_ message: String) {
        print("📮 Feedback submitted: \(message)")
    }

    @ViewBuilder
    private func settingsButton(
        title: String,
        action: (() -> Void)? = nil,
        trailing: (() -> AnyView)? = nil,
        isDisabled: Bool = false
    ) -> some View {
        Button(action: { action?() }) {
            HStack {
                Text(title)
                    .foregroundColor(.white)
                    .fontWeight(.medium)
                Spacer()
                if let trailing = trailing {
                    trailing()
                } else if !isDisabled {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white.opacity(0.5))
                }
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
    SettingsScreen()
        .environment(Router())
}
