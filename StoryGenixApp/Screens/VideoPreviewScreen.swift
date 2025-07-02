// VideoPreviewScreen.swift
// StoryGenixApp

import SwiftUI
import AVKit
import Combine

struct VideoPreviewScreen: View {
    let script: String

    @StateObject private var viewModel = VideoPreviewViewModel()
    @State private var player = AVPlayer()
    @State private var showSelectionWarning = false
    @Environment(Router.self) private var router

    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("StoryGenix")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)

                Text("Preview Your Video")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        if viewModel.scenes.indices.contains(viewModel.currentSceneIndex) {
                            let currentScene = viewModel.scenes[viewModel.currentSceneIndex]

                            ScriptPromptSection(
                                sceneText: currentScene.sceneText,
                                prompt: currentScene.prompt,
                                sceneIndex: viewModel.currentSceneIndex,
                                totalScenes: viewModel.scenes.count,
                                onUpdatePrompt: { newPrompt in
                                    viewModel.updatePrompt(for: viewModel.currentSceneIndex, newPrompt: newPrompt)
                                },
                                onGenerate: {
                                    viewModel.generateVideo(for: viewModel.currentSceneIndex)
                                },
                                onPrevious: {
                                    if viewModel.currentSceneIndex > 0 {
                                        viewModel.currentSceneIndex -= 1
                                        showSelectionWarning = false
                                    }
                                },
                                onNext: {
                                    if currentScene.videoURL == nil {
                                        withAnimation {
                                            showSelectionWarning = true
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            withAnimation {
                                                showSelectionWarning = false
                                            }
                                        }
                                    } else if viewModel.currentSceneIndex < viewModel.scenes.count - 1 {
                                        viewModel.currentSceneIndex += 1
                                    }
                                },
                                canGoPrevious: viewModel.currentSceneIndex > 0,
                                canGoNext: viewModel.currentSceneIndex < viewModel.scenes.count - 1,
                                isLoading: viewModel.isLoading,
                                shouldShowNavigation: true,
                                generateButtonTitle: "Generate Video"
                            )

                            if showSelectionWarning {
                                Text("Please generate video before continuing.")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.red)
                                    .transition(.opacity)
                                    .padding(.top, -6)
                            }

                            if let videoURL = currentScene.videoURL {
                                VideoPlayer(player: player)
                                    .frame(height: 300)
                                    .padding(.horizontal, 55)
                                    .cornerRadius(12)
                                    .padding()
                                    .onReceive(Just(videoURL)) { url in
                                        player.replaceCurrentItem(with: AVPlayerItem(url: url))
                                        player.play()
                                    }

                                HStack {
                                    Button("← Previous") {
                                        if viewModel.currentSceneIndex > 0 {
                                            viewModel.currentSceneIndex -= 1
                                            showSelectionWarning = false
                                        }
                                    }
                                    .disabled(viewModel.currentSceneIndex == 0)

                                    Spacer()

                                    Button("Next →") {
                                        if currentScene.videoURL == nil {
                                            withAnimation {
                                                showSelectionWarning = true
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                withAnimation {
                                                    showSelectionWarning = false
                                                }
                                            }
                                        } else if viewModel.currentSceneIndex < viewModel.scenes.count - 1 {
                                            viewModel.currentSceneIndex += 1
                                        }
                                    }
                                    .disabled(viewModel.currentSceneIndex >= viewModel.scenes.count - 1)
                                }
                                .padding(.horizontal, 40)
                                .foregroundColor(.white)

                                if viewModel.currentSceneIndex == viewModel.scenes.count - 1 {
                                    SecondaryActionButton(title: "Continue to Final") {
                                         router.goToVideoComplete()
                                    }
                                    .padding(.horizontal, 30)
                                }

                                Button("Regenerate Video") {
                                    viewModel.generateVideo(for: viewModel.currentSceneIndex)
                                }
                                .foregroundColor(.white)
                            }
                        }

                        Spacer(minLength: 40)
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadScenes(from: script)
        }
    }
}

#Preview {
    VideoPreviewScreen(script: """
    The human eye is one of the most extraordinary organs in the body.
    It captures light, interprets color, and helps us understand the world around us.

    Behind every blink is a complex system — the cornea, lens, and retina all working together like a perfect machine.
    """)
}
