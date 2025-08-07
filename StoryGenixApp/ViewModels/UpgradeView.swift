//
//  UpgradeView.swift
//  StoryGenix
//
//  Created by Elif Edman on 1.08.2025.
//

import SwiftUI
import AuthenticationServices
import FirebaseAuth

struct UpgradeView: View {
    @State private var currentNonce: String?

    var body: some View {
        SignInWithAppleButton(.signIn) { request in
            let nonce = NonceHelper.randomNonceString()
            currentNonce = nonce
            request.requestedScopes = [.fullName, .email]
            request.nonce = NonceHelper.sha256(nonce)
        } onCompletion: { result in
            switch result {
            case .success(let authResults):
                if let appleCredential = authResults.credential as? ASAuthorizationAppleIDCredential,
                   let identityToken = appleCredential.identityToken,
                   let tokenString = String(data: identityToken, encoding: .utf8),
                   let nonce = currentNonce {
                    
                    let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                              idToken: tokenString,
                                                              rawNonce: nonce)
                    
                    AuthManager.shared.linkAccount(with: credential) { linkResult in
                        switch linkResult {
                        case .success(let user):
                            print("✅ Upgraded account: \(user.uid)")
                        case .failure(let error):
                            print("❌ Linking failed: \(error.localizedDescription)")
                        }
                    }
                }
            case .failure(let error):
                print("❌ Apple Sign In failed: \(error.localizedDescription)")
            }
        }
        .signInWithAppleButtonStyle(.black)
        .frame(height: 50)
        .padding()
    }
}
