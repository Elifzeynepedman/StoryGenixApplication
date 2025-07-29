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
        ZStack(alignment: .top) {
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
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                player.play()
                            }
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

                    PrimaryGradientButton(title: "Share Video", isLoading: false) {
                        isSharing = true
                    }

                    Button(action: {
                        var updated = project
                        updated.isCompleted = true
                        updated.progressStep = 4

                        viewModel.replaceWithCompleted(updated) // ✅ cleans up old unfinished version

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

            if showDownloadSuccess {
                Text("✅ Video successfully downloaded")
                    .font(.callout.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color("DarkTextColor").opacity(0.85))
                    .clipShape(Capsule())
                    .padding(.top, 20)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $isSharing) {
            if let url = videoURL {
                ShareSheetView(items: [url])
            }
        }
    }
}

#Preview {
    VideoCompleteScreen(project: VideoProject(
        title: "Sample Project",
        script: "The eye sees the world.",
        thumbnail: "sampleThumbnail",
        scenes: [],
        isCompleted: false,
        progressStep: 3
    ))
    .environment(Router())
    .environmentObject(ProjectsViewModel())
}
