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
            // Background
            Image("BackgroundImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    // Header
                    VStack(spacing: 4) {
                        Text("Settings")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                        Text("Manage your account and preferences")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.top, 50)

                    // Account
                    settingsSection(title: "ACCOUNT") {
                        settingsRowWithTrailing(icon: "crown.fill", title: "Subscription") {
                            Text("Pro")
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    LinearGradient(colors: [.blue, .pink],
                                                   startPoint: .topLeading,
                                                   endPoint: .bottomTrailing)
                                )
                                .clipShape(Capsule())
                                .foregroundColor(.white)
                        }
                    }

                    // App
                    settingsSection(title: "APP") {
                        settingsRow(icon: "gear", title: "App Settings") {
                            router.goToAppSettings()
                        }
                        settingsRow(icon: "envelope.fill", title: "Contact Us") {
                            router.goToContact()
                        }
                    }

                    // Feedback
                    settingsSection(title: "FEEDBACK") {
                        settingsRow(icon: "lightbulb.fill", title: "Improvements") {
                            showFeedbackModal = true
                        }
                        settingsRow(icon: "ant.fill", title: "Report a Bug") {
                            showBugModal = true
                        }
                    }

                    // Info
                    settingsSection(title: "INFO") {
                        settingsRowWithTrailing(icon: "person.text.rectangle", title: "User ID") {
                            Text(userId)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal)
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showBugModal) {
                FeedbackModalView(title: "Report a Bug", placeholder: "Brief description of the bug", emoji: "🐞", onSubmit: submitBugReport, isPresented: $showBugModal)
            }
            .sheet(isPresented: $showFeedbackModal) {
                FeedbackModalView(title: "Improvements", placeholder: "How can we improve?", emoji: "💡", onSubmit: submitFeedback, isPresented: $showFeedbackModal)
            }
        }

    // MARK: - Helpers

    private func settingsSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.06))
                .padding(.horizontal)
            content()
        }
    }

    // ✅ Row for action only
    private func settingsRow(
        icon: String,
        title: String,
        showArrow: Bool = true,
        action: @escaping () -> Void
    ) -> some View {
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

                if showArrow {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    // ✅ Row for trailing view (no tap action)
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

    private func submitBugReport(_ message: String) {
        print("📮 Bug submitted: \(message)")
    }

    private func submitFeedback(_ message: String) {
        print("📮 Feedback submitted: \(message)")
    }
}

#Preview {
    SettingsScreen()
        .environment(Router())
}

