//
//  OnboardingPage.swift
//  StoryGenix
//
//  Created by Elif Edman on 3.08.2025.


import SwiftUI
import AVKit

struct OnboardingPage: View {
    var title: String
    var subtitle: String
    var videoName: String
    var heroText: String
    var voiceScript: String? = nil
    var buttonTitle: String
    var action: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            // ✅ Background Video
            if let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") {
                FullscreenVideoView(player: AVPlayer(url: url))
                    .ignoresSafeArea()
            } else {
                Color.black
            }

            if !heroText.isEmpty {
                Text(heroText)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .padding(16)
                    .background(Color.black.opacity(0.3).blur(radius: 5))
                    .cornerRadius(12)
                    .padding(.top, 90)
                    .padding(.leading, 16)
                    .shadow(radius: 6)
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.6, alignment: .leading)
                    .transition(.opacity)
                    .animation(.easeIn(duration: 1.2), value: heroText)
            }
            
            if let script = voiceScript {
                VStack(alignment: .leading, spacing: 8) {
                    Text("AI Voice Script")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.8))
                    Text("“\(script)”")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .padding(12)
                        .background(Color.black.opacity(0.35))
                        .cornerRadius(10)
                }
                .padding(.horizontal, 20)
                .padding(.top, 100)
                .frame(maxWidth: .infinity, alignment: .leading)
                .transition(.opacity)
                .animation(.easeIn(duration: 1.2), value: script)
            }

            // ✅ Bottom UI
            VStack {
                Spacer()
                VStack(spacing: 12) {
                    Text(title)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)

                    Text(subtitle)
                        .font(.system(size: 17))
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .padding(.bottom, 24)

                Button(action: action) {
                    Text(buttonTitle)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [
                                    Color("ButtonGradient1"),
                                    Color("ButtonGradient2"),
                                    Color("ButtonGradient3")
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
        }
        .ignoresSafeArea()
    }
}
