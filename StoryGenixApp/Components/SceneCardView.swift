//
//  SceneCardView.swift
//  StoryGenix
//
//  Created by Elif Edman on 2.08.2025.
//

import SwiftUI
import AVKit

struct SceneCardView: View {
    let scene: VideoScene
    let index: Int
    let totalScenes: Int
    let project: VideoProject
    @Binding var player: AVPlayer

    let onPrevious: () -> Void
    let onNext: () -> Void
    let onContinue: () -> Void
    let onShowWarning: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 14) {
                Text("Scene \(index + 1) of \(totalScenes)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))

                Text(scene.sceneText)
                    .font(.headline)
                    .foregroundColor(.white)

                if let videoURL = scene.videoURL {
                    VideoPlayer(player: player)
                        .frame(height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(radius: 6)
                        .onAppear {
                            player.replaceCurrentItem(with: AVPlayerItem(url: videoURL))
                            player.play()
                        }
                }
            }
            .padding()
            .background(Color.black.opacity(0.25))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)

            if scene.videoURL != nil {
                HStack {
                    if index > 0 {
                        navButton(title: "← Previous", action: onPrevious)
                    }
                    Spacer()
                    if index < totalScenes - 1 {
                        navButton(title: "Next →", action: onNext)
                    }
                }
                .padding(.horizontal, 16)

                if index == totalScenes - 1 {
                    PrimaryGradientButton(
                        title: "Continue to Final",
                        isLoading: false,
                        action: onContinue
                    )
                    .padding(.top, 10)
                }
            }
        }
    }

    private func navButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(Color.white.opacity(0.1))
                .clipShape(Capsule())
                .foregroundColor(.white)
        }
    }
}
