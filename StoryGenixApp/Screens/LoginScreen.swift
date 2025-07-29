//
//  LoginScreen.swift
//  StoryGenix
//
//  Created by Elif Edman on 29.07.2025.
//

import SwiftUI

struct LoginScreen: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var loginMessage: String = ""

    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Login to StoryGenIX")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.bottom, 20)

                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)

                Button {
                    Task { await loginUser() }
                } label: {
                    if isLoading {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(height: 44)
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    } else {
                        Text("Login")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(height: 44)
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(colors: [Color.purple, Color.pink],
                                               startPoint: .leading,
                                               endPoint: .trailing)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding(.horizontal, 60)
                .padding(.top, 10)

                if !loginMessage.isEmpty {
                    Text(loginMessage)
                        .foregroundColor(.white)
                        .padding(.top, 10)
                }

                Spacer()
            }
        }
    }

    private func loginUser() async {
        guard !email.isEmpty, !password.isEmpty else {
            loginMessage = "Please fill in all fields"
            return
        }

        isLoading = true
        do {
            let token = try await AuthService.shared.login(email: email, password: password)
            loginMessage = "✅ Logged in! Token: \(token.prefix(10))..."
        } catch {
            loginMessage = "❌ Login failed: \(error.localizedDescription)"
        }
        isLoading = false
    }
}

#Preview {
    LoginScreen()
}
