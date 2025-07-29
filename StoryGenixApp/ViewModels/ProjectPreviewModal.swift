//
//  ProjectPreviewModal.swift
//  StoryGenix
//
//  Created by Elif Edman on 5.07.2025.
//

import SwiftUI
import AVKit

struct ProjectPreviewModal: View {
    let project: VideoProject
    @Binding var isPresented: Bool

    @State private var player = AVPlayer()
    @State private var isSharing = false
    @State private var showDownloadSuccess = false

    private var videoURL: URL? {
        Bundle.main.url(forResource: "EfesVideo", withExtension: "mp4") // Mock only
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color("DarkTextColor")
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text(project.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 140)

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
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.black.opacity(0.2))
                        .frame(width: 320, height: 320)
                        .overlay(
                            Text("Video not found")
                                .foregroundColor(.white.opacity(0.7))
                        )
                }

                VStack(spacing: 16) {
                    // ✅ Download Button
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

                    // ✅ Share Button
                    PrimaryGradientButton(title: "Share Video", isLoading: false) {
                        isSharing = true
                    }

                    // ✅ Close
                    Button("Close") {
                        isPresented = false
                    }
                    .foregroundColor(.white.opacity(0.7))
                    .underline()
                    .padding(.top, 8)
                }
                .padding(.horizontal, 32)

                Spacer()
            }

            // ✅ Top Download Success Toast
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
        .sheet(isPresented: $isSharing) {
            if let url = videoURL {
                ShareSheetView(items: [url])
            }
        }
    }
}
