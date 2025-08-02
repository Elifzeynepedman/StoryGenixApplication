//
//  EmailLoginScreen.swift
//  StoryGenix
//
//  Created by Elif Edman on 1.08.2025.
//

import SwiftUI
import FirebaseAuth

struct EmailLoginScreen: View {
    @Environment(\.dismiss) var dismiss
    @Binding var showLoginSheet: Bool
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSignUpMode = false
    @State private var isLoading = false
    @State private var message: String = ""
    @State private var showResendOption = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 16) {
                Capsule()
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 40, height: 5)
                    .padding(.top, 10)
                
                Text(isSignUpMode ? "Create Account" : "Sign In")
                    .foregroundColor(.white)
                    .font(.system(size: 22, weight: .semibold))
                    .padding(.top, 4)
                
                VStack(spacing: 10) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .frame(height: 50)
                        .background(.ultraThinMaterial)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .padding()
                        .frame(height: 50)
                        .background(.ultraThinMaterial)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                
                if isSignUpMode {
                    Text("Password must be at least 6 characters")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 4)
                }
                
                Button(action: {
                    Task {
                        if isSignUpMode { await signUpUser() }
                        else { await loginUser() }
                    }
                }) {
                    if isLoading {
                        ProgressView().tint(.white)
                            .frame(height: 44)
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    } else {
                        Text(isSignUpMode ? "Sign Up" : "Sign In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(colors: [
                                    Color("ButtonGradient1"),
                                    Color("ButtonGradient2")
                                ], startPoint: .leading, endPoint: .trailing)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.horizontal, 24)
                .disabled(isLoading)
                
                if !message.isEmpty {
                    Text(message)
                        .foregroundColor(.white)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.top, 6)
                }
                
                if showResendOption {
                    Button(action: {
                        Task { await resendVerificationEmail() }
                    }) {
                        Text("Resend Verification Email")
                            .font(.footnote)
                            .foregroundColor(Color("ButtonGradient2"))
                            .underline()
                    }
                }
                
                if !isSignUpMode {
                    Button(action: {
                        Task { await forgotPassword() }
                    }) {
                        Text("Forgot Password?")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.8))
                            .underline()
                    }
                }
                
                Spacer()
                
                Button(action: { isSignUpMode.toggle() }) {
                    Text(isSignUpMode ? "Already have an account? Sign In" :
                                        "Don't have an account? Sign Up")
                        .foregroundColor(.white.opacity(0.9))
                        .font(.subheadline)
                        .underline()
                }
                
                Button(action: { dismiss() }) {
                    Text("Cancel")
                        .foregroundColor(.white.opacity(0.7))
                        .underline()
                }
                .padding(.bottom, 20)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .ignoresSafeArea(.keyboard)
    }
    
    // MARK: - Firebase Logic
    private func loginUser() async {
        guard !email.isEmpty, !password.isEmpty else {
            message = "Please fill in all fields"
            return
        }
        isLoading = true
        showResendOption = false
        do {
            let user = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<User, Error>) in
                Auth.auth().signIn(withEmail: email, password: password) { result, error in
                    if let error = error { continuation.resume(throwing: error) }
                    else if let user = result?.user { continuation.resume(returning: user) }
                }
            }
            try await user.reload()
            if !user.isEmailVerified {
                message = "Please verify your email before signing in."
                showResendOption = true
                try await Auth.auth().signOut()
            } else {
                APIManager.shared.syncUser(firebaseUid: user.uid, email: user.email, username: "anonymous")
                message = "✅ Logged in successfully!"
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showLoginSheet = false
                }
            }
        } catch {
            message = "❌ Login failed: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    private func signUpUser() async {
        guard !email.isEmpty, !password.isEmpty else {
            message = "Please fill in all fields"
            return
        }
        isLoading = true
        showResendOption = false
        do {
            let user = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<User, Error>) in
                Auth.auth().createUser(withEmail: email, password: password) { result, error in
                    if let error = error { continuation.resume(throwing: error) }
                    else if let user = result?.user { continuation.resume(returning: user) }
                }
            }
            try await user.sendEmailVerification()
            APIManager.shared.syncUser(firebaseUid: user.uid, email: user.email, username: "anonymous")
            message = "✅ Verification email sent. Please check your inbox."
            showResendOption = true
        } catch {
            message = "❌ Sign Up failed: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    private func forgotPassword() async {
        guard !email.isEmpty else {
            message = "Please enter your email first."
            return
        }
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            message = "✅ Password reset email sent!"
        } catch {
            message = "❌ Failed: \(error.localizedDescription)"
        }
    }
    
    private func resendVerificationEmail() async {
        guard let user = Auth.auth().currentUser else {
            message = "Please sign in first."
            return
        }
        do {
            try await user.reload()
            try await user.sendEmailVerification()
            message = "✅ Verification email sent again!"
        } catch {
            message = "❌ Failed: \(error.localizedDescription)"
        }
    }
}

