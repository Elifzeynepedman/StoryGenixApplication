//
//  VideoPreviewScreen.swift
//  StoryGenixApp
//
//  Created by Elif Edman on 29.06.2025.
//

import SwiftUI
import AVKit

struct VideoPreviewScreen: View {
    @StateObject private var viewModel = VideoPreviewViewModel()
    @State private var player: AVPlayer?
    private let squareSize: CGFloat = 350
    //@Environment(Router.self) private var router


    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("VidGenius")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 16)

                Text("Generate Your Video")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
        
                Text("Scene \(viewModel.currentSceneIndex + 1) of \(viewModel.scenes.count)")
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .padding(.horizontal, 4)

                // --- Video or Placeholder (always perfectly square)
                ZStack {
                    if let url = viewModel.currentScene?.videoURL {
                        VideoPlayer(player: player ?? AVPlayer(url: url))
                            .onAppear {
                                if player == nil, let url = viewModel.currentScene?.videoURL {
                                    player = AVPlayer(url: url)
                                    player?.play()
                                }
                            }
                            .onChange(of: viewModel.currentSceneIndex) {
                                if let url = viewModel.currentScene?.videoURL {
                                    player = AVPlayer(url: url)
                                    player?.play()
                                }
                            }
                            .onDisappear {
                                player?.pause()
                            }
                            .aspectRatio(1, contentMode: .fill)
                            .frame(width: squareSize, height: squareSize)
                            .cornerRadius(18)
                            .shadow(radius: 8)
                    } else if let imageName = viewModel.currentScene?.previewImage {
                        Image(imageName)
                            .resizable()
                            .aspectRatio(1, contentMode: .fill)
                            .frame(width: squareSize, height: squareSize)
                            .cornerRadius(18)
                            .shadow(radius: 8)
                    }
                }

                // --- Scene Navigation
                HStack {
                    Button("← Previous") {
                        viewModel.prevScene()
                        player?.pause()
                        player = nil
                    }
                    .disabled(viewModel.currentSceneIndex == 0)

                    Spacer()

                    Button("Next →") {
                        if viewModel.currentSceneIndex < viewModel.scenes.count - 1 {
                            viewModel.nextScene()
                            player?.pause()
                            player = nil
                        }
                    }
                    .disabled(viewModel.currentSceneIndex >= viewModel.scenes.count - 1)
                }
                .padding(.horizontal, 40)
                .foregroundColor(.white)
                .padding(.top, 8)
                
                VStack(spacing: 16) {
                    PrimaryGradientButton(title: "Regenerate Video", isLoading: false) {
                        // Regenerate video logic
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 12)
                    
                    if viewModel.isOnLastScene {
                        SecondaryActionButton(title: "Complete Video") {
                            // Complete video logic
                        }
                        .padding(.horizontal, 28)
                    } else {
                        Color.clear
                            .frame(height: 44)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 28)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)



                Spacer()
            }
            .padding(.top, 30)
        }
        .navigationBarBackButtonHidden(true)

    }
}

// MARK: - Preview
#Preview {
    VideoPreviewScreen()
}
