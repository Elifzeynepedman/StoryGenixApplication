//
//  LoginScreen.swift
//  StoryGenix
//
//  Created by Elif Edman on 29.07.2025.
//

import SwiftUI
import AuthenticationServices
import GoogleSignIn
import FirebaseAuth
import Firebase

struct LoginScreen: View {
    @Binding var showLoginSheet: Bool
    @State private var showEmailLogin = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                Text("Sign in to Continue")
                    .foregroundColor(.white)
                    .font(.system(size: 24, weight: .bold))
                    .padding(.bottom, 8)
                
                // ✅ Apple Sign-In
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    handleAppleSignIn(result: result)
                }
                .signInWithAppleButtonStyle(SignInWithAppleButton.Style.white)
                .frame(height: 50)
                .cornerRadius(8)
                .padding(.horizontal)
                
                // ✅ Google Sign-In
                Button(action: {
                    signInWithGoogle()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "g.circle.fill")
                            .font(.title2)
                        Text("Continue with Google")
                            .font(.headline)
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.white)
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                
                // ✅ Email Login
                Button(action: {
                    showEmailLogin = true
                }) {
                    Text("Continue with Email")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: { showLoginSheet = false }) {
                    Text("Cancel")
                        .foregroundColor(.white.opacity(0.8))
                        .underline()
                }
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showEmailLogin) {
            EmailLoginScreen(showLoginSheet: $showLoginSheet)
        }
    }
    
    // MARK: - Google Sign-In
    private func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("❌ Missing Firebase clientID")
            return
        }
        
        guard let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.windows.first?.rootViewController }).first else {
            print("❌ Could not get root view controller")
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { signInResult, error in
            if let error = error {
                print("❌ Google Sign-In failed: \(error.localizedDescription)")
                return
            }
            
            guard let user = signInResult?.user,
                  let idToken = user.idToken?.tokenString else {
                print("❌ Google user or token missing")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    print("❌ Firebase Google login failed: \(error.localizedDescription)")
                } else if let user = result?.user {
                    print("✅ Logged in with Google: \(user.uid)")
                    APIManager.shared.syncUser(firebaseUid: user.uid, email: user.email, username: user.displayName)
                    showLoginSheet = false
                }
            }
        }
    }
    
    // MARK: - Apple Sign-In
    private func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authResults):
            if let credential = authResults.credential as? ASAuthorizationAppleIDCredential,
               let identityToken = credential.identityToken,
               let tokenString = String(data: identityToken, encoding: .utf8) {
                
                let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com",
                                                                  idToken: tokenString,
                                                                  rawNonce: "random-nonce") // Replace with a real nonce
                
                Auth.auth().signIn(with: firebaseCredential) { result, error in
                    if let error = error {
                        print("❌ Firebase Apple sign-in error: \(error.localizedDescription)")
                    } else if let user = result?.user {
                        print("✅ Logged in with Apple: \(user.uid)")
                        APIManager.shared.syncUser(firebaseUid: user.uid, email: user.email, username: user.displayName)
                        showLoginSheet = false
                    }
                }
            }
        case .failure(let error):
            print("❌ Apple sign-in error: \(error.localizedDescription)")
        }
    }
}

#Preview {
    LoginScreen(showLoginSheet: .constant(true))
}
