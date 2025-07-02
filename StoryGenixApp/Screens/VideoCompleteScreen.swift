//
//  VideoCompleteScreen.swift
//  StoryGenixApp
//
//  Created by Elif Edman on 30.06.2025.
//

import SwiftUI
import AVKit

struct VideoCompleteScreen: View {
    private let videoURL = Bundle.main.url(forResource: "EfesVideo", withExtension: "mp4")
    @State private var player: AVPlayer = AVPlayer()
    @State private var isSharing = false
    @State private var showDownloadSuccess = false
    
    @Environment(Router.self) private var router

    


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
                    .padding(.top, 16)

                Text("Your Video Is Ready")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

                Text("The video has been generated successfully")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))

                if let url = videoURL {
                    VideoPlayer(player: player)
                        .onAppear {
                            player.replaceCurrentItem(with: AVPlayerItem(url: url))
                            player.play()
                        }
                        .frame(width: 320, height: 320)
                        .cornerRadius(18)
                        .shadow(radius: 8)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.black.opacity(0.2))
                            .frame(width: 320, height: 320)
                        Text("Video not found")
                            .foregroundColor(.white.opacity(0.7))
                    }
                }

                VStack(spacing: 16) {
                    Button(action: {
                        if let url = videoURL {
                            MediaSaver.saveVideoToPhotoLibrary(from: url) { success in
                                if success {
                                    print("Video saved successfully.")
                                    // Optional: Show confirmation toast
                                } else {
                                    print("Failed to save video.")
                                }
                            }
                        }
                    }) {
                        Text("Download Video")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            )
                    }

                    PrimaryGradientButton(title: "Share Video", isLoading: false){
                       isSharing = true
                    }

                    Button(action: {
                        // Navigate back to home
                        router.goToHome()
                    }) {
                        Text("Return to Home")
                            .foregroundColor(.white)
                            .underline()
                    }
                }
                .padding(.horizontal, 32)

                Spacer()
            }
            .padding(.top, 30)
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $isSharing) {
            if let url = videoURL {
                ShareSheetView(items: [url])
            }
        }

    }
}

// MARK: - Preview
#Preview {
    VideoCompleteScreen()
}
