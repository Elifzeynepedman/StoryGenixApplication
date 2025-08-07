//
//  VideoCompleteScreen.swift
//  StoryGenixApp
//
//  Created by Elif Edman on 30.06.2025.
//

import SwiftUI
import AVKit

struct VideoCompleteScreen: View {
    let project: VideoProject

    @EnvironmentObject private var viewModel: ProjectsViewModel
    @Environment(Router.self) private var router

    private let videoURL = Bundle.main.url(forResource: "EfesVideo", withExtension: "mp4")
    @State private var player: AVPlayer = AVPlayer()
    @State private var isSharing = false
    @State private var showDownloadSuccess = false

    var body: some View {
        ZStack {
            // ✅ Background
            Image("BackgroundImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // ✅ Header
                VStack(spacing: 6) {
                    Text("My AI Director")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    Text("Your Video is Ready")
                        .font(.title2.bold())
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.top, 40)

                // ✅ Glass Video Card
                VStack(spacing: 16) {
                    if let url = videoURL {
                        VideoPlayer(player: player)
                            .frame(height: 240)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .shadow(radius: 8)
                            .onAppear {
                                player.replaceCurrentItem(with: AVPlayerItem(url: url))
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    player.play()
                                }
                            }
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.black.opacity(0.2))
                                .frame(height: 240)
                            Text("Video not found")
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
                .padding()
                .background(
                    ZStack {
                        Color.black.opacity(0.25)
                        LinearGradient(
                            colors: [
                                Color("BackgroundGradientDark").opacity(0.15),
                                Color("BackgroundGradientPurple").opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                .padding(.horizontal)

                // ✅ Buttons Section
                VStack(spacing: 16) {
                    // Download Button
                    Button(action: downloadVideo) {
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

                    // Share Button
                    PrimaryGradientButton(title: "Share Video", isLoading: false) {
                        isSharing = true
                    }

                    // Return to Home
                    Button(action: {
                        var updated = project
                        updated.isCompleted = true
                        updated.progressStep = .completed
                        viewModel.replaceWithCompleted(updated)
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

            // ✅ Floating iOS-style success toast
            if showDownloadSuccess {
                VStack {
                    Spacer()
                    Text("✅ Video saved to Photos")
                        .font(.callout.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                        .padding(.bottom, 40)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.easeInOut, value: showDownloadSuccess)
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $isSharing) {
            if let url = videoURL {
                ShareSheetView(items: [url])
            }
        }
    }

    // ✅ Download Logic
    private func downloadVideo() {
        if let url = videoURL {
            MediaSaver.saveVideoToPhotoLibrary(from: url) { success in
                if success {
                    withAnimation {
                        showDownloadSuccess = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showDownloadSuccess = false
                        }
                    }
                }
            }
        }
    }
}
