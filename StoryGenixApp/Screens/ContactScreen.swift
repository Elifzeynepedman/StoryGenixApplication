//
//  ContactScreen.swift
//  StoryGenix
//
//  Created by Elif Edman on 5.07.2025.
//

import SwiftUI

struct ContactScreen: View {
    @Environment(Router.self) private var router
    @State private var message = ""

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

                Text("Contact Us")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

                Text("Let us know your questions or feedback.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)

                TextField("Type your message...", text: $message, axis: .vertical)
                    .lineLimit(4...8)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .padding(.horizontal)

                HStack(spacing: 16) {
                    Button("Cancel") {
                        router.path.removeLast()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .foregroundColor(.white)

                    Button("Submit") {
                        sendMessage(message)
                        router.path.removeLast()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .foregroundColor(.white)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }

    func sendMessage(_ text: String) {
        print("📮 Contact message sent: \(text)")
        // TODO: Connect to /api/feedback/contact if backend is live
    }
}

#Preview {
    ContactScreen()
        .environment(Router())
}
