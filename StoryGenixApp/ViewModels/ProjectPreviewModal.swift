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
    @GestureState private var dragOffset: CGFloat = 0

    private var videoURL: URL? {
        Bundle.main.url(forResource: "EfesVideo", withExtension: "mp4")
    }

    var body: some View {
        ZStack {
            Color(red: 31/255, green: 17/255, blue: 71/255)
                .opacity(0.6) // Adjust this for more/less transparency
                .ignoresSafeArea()


            VStack(spacing: 20) {
                // Drag Handle
                Capsule()
                    .fill(Color.white.opacity(0.4))
                    .frame(width: 40, height: 4)
                    .padding(.top, 8)

                // ✅ Video Preview
                if let url = videoURL {
                    VideoPlayer(player: player)
                        .frame(height: 220)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(radius: 8)
                        .onAppear {
                            player.replaceCurrentItem(with: AVPlayerItem(url: url))
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                player.play()
                            }
                        }
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black.opacity(0.3))
                        .frame(height: 220)
                        .overlay(Text("Video not found").foregroundColor(.white.opacity(0.7)))
                }

                // Project Title
                Text(project.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                // ✅ Buttons Section
                VStack(spacing: 14) {
                    // Glass Download Button
                    Button(action: downloadVideo) {
                        Text("Download Video")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    }

                    // Primary Gradient Button for Share
                    PrimaryGradientButton(title: "Share Video", isLoading: false) {
                        isSharing = true
                    }

                    // Close link
                    Button(action: dismiss) {
                        Text("Close")
                            .foregroundColor(.white.opacity(0.8))
                            .underline()
                            .padding(.top, 6)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)

            }
            .frame(maxWidth: 380)
            .padding(.horizontal, 16)
            .offset(y: dragOffset > 0 ? dragOffset : 0)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        if value.translation.height > 0 {
                            state = value.translation.height
                        }
                    }
                    .onEnded { value in
                        if value.translation.height > 150 {
                            dismiss()
                        }
                    }
            )
            .transition(.move(edge: .bottom))
            .animation(.spring(), value: dragOffset)

            // ✅ Download Success Toast
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
        .sheet(isPresented: $isSharing) {
            if let url = videoURL {
                ShareSheetView(items: [url])
            }
        }
    }

    private func downloadVideo() {
        if let url = videoURL {
            MediaSaver.saveVideoToPhotoLibrary(from: url) { success in
                if success {
                    withAnimation { showDownloadSuccess = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation { showDownloadSuccess = false }
                    }
                }
            }
        }
    }

    private func dismiss() {
        withAnimation(.spring()) {
            isPresented = false
        }
    }
}
