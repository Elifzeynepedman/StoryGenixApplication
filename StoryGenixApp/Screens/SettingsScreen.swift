//
//  SettingsScreen.swift
//  StoryGenix
//
//  Created by Elif Edman on 2.07.2025.
//

import SwiftUI
import FirebaseAuth

struct SettingsScreen: View {
    @Environment(Router.self) private var router
    @StateObject private var authViewModel = AuthViewModel() // ✅ Observe Firebase Auth
    @State private var showBugModal = false
    @State private var showFeedbackModal = false
    @State private var showLoginSheet = false
    @State private var showLogoutAlert = false
    
    var body: some View {
        ZStack {
            // ✅ Background
            Image("BackgroundImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 28) {
                    
                    // ✅ Header with Greeting
                    VStack(spacing: 6) {
                        Text("Settings")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(authViewModel.user?.email ?? "Hello, Guest")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.85))
                        
                        Text("Manage your account and preferences")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.top, 50)
                    
                    // ✅ Account Section
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
                        
                        settingsRowWithTrailing(icon: "person.text.rectangle", title: "User ID") {
                            Text(authViewModel.user?.uid ?? "N/A")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    // ✅ App Section
                    settingsSection(title: "APP") {
                        settingsRow(icon: "gear", title: "App Settings") {
                            router.goToAppSettings()
                        }
                        settingsRow(icon: "envelope.fill", title: "Contact Us") {
                            router.goToContact()
                        }
                    }
                    
                    // ✅ Feedback Section
                    settingsSection(title: "FEEDBACK") {
                        settingsRow(icon: "lightbulb.fill", title: "Improvements") {
                            showFeedbackModal = true
                        }
                        settingsRow(icon: "ant.fill", title: "Report a Bug") {
                            showBugModal = true
                        }
                    }
                    
                    // ✅ Info Section
                    settingsSection(title: "INFO") {
                        settingsRowWithTrailing(icon: "info.circle", title: "App Version") {
                            Text("v1.0.0")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    // ✅ Dynamic Button: Sign In OR Log Out
                    if authViewModel.user == nil {
                        Button(action: { showLoginSheet = true }) {
                            Text("Sign In or Create Account")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                    } else {
                        Button(action: { showLogoutAlert = true }) {
                            Text("Log Out")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal)
            }
        }
        .navigationBarBackButtonHidden(true)
        // ✅ Modals
        .sheet(isPresented: $showBugModal) {
            FeedbackModalView(title: "Report a Bug",
                               placeholder: "Brief description of the bug",
                               emoji: "🐞",
                               onSubmit: submitBugReport,
                               isPresented: $showBugModal)
        }
        .sheet(isPresented: $showFeedbackModal) {
            FeedbackModalView(title: "Improvements",
                               placeholder: "How can we improve?",
                               emoji: "💡",
                               onSubmit: submitFeedback,
                               isPresented: $showFeedbackModal)
        }
        .sheet(isPresented: $showLoginSheet) {
            NavigationStack {
                LoginScreen(showLoginSheet: $showLoginSheet)
                    .preferredColorScheme(.dark)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
        // ✅ iOS-style alert for log out
        .alert("Are you sure you want to log out?", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Log Out", role: .destructive) {
                authViewModel.signOut()
            }
        }
    }
    
    // MARK: - UI Helpers
    private func settingsSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.06))
                .padding(.horizontal)
            content()
        }
    }
    
    private func settingsRow(icon: String, title: String, showArrow: Bool = true, action: @escaping () -> Void) -> some View {
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

