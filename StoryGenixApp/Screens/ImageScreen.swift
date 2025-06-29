//
//  ImageScreen.swift
//  StoryGenix
//
//  Created by Elif Edman on 29.06.2025.
//
import SwiftUI

struct ImageScreen: View {
    let script: String

    @StateObject private var viewModel = ImageViewModel()
    @State private var showSelectionWarning = false
    @Environment(Router.self) private var router

    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("VidGenius")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)

                Text("Generate Your Images")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

                SegmentedToggle(options: viewModel.aspectOptions, selected: $viewModel.selectedAspect)
                    .padding(.horizontal, 35)

                Button(action: {
                    viewModel.generateImages(for: viewModel.currentSceneIndex)
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(height: 44)
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    } else {
                        Text("Generate Images")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(height: 44)
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    colors: [Color.purple, Color.pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding(.horizontal, 80)

                if viewModel.scenes.indices.contains(viewModel.currentSceneIndex) {
                    let currentScene = viewModel.scenes[viewModel.currentSceneIndex]

                    Text("Scene \(viewModel.currentSceneIndex + 1) of \(viewModel.scenes.count)")
                        .foregroundColor(.white)
                        .font(.subheadline)

                    ImageSceneCardView(
                        scene: currentScene,
                        onSelect: { selectedImage in
                            viewModel.selectImage(selectedImage, for: viewModel.currentSceneIndex)
                        }
                    )
                }

                if showSelectionWarning {
                    Text("Please select an image before continuing.")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.red)
                        .transition(.opacity)
                        .padding(.top, -6)
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
                        let current = viewModel.currentSceneIndex
                        if viewModel.scenes.indices.contains(current),
                           viewModel.scenes[current].selectedImage == nil {
                            withAnimation {
                                showSelectionWarning = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showSelectionWarning = false
                                }
                            }
                        } else {
                            if current < viewModel.scenes.count - 1 {
                                viewModel.currentSceneIndex += 1
                            }
                        }
                    }
                    .disabled(viewModel.currentSceneIndex >= viewModel.scenes.count - 1)
                }
                .padding(.horizontal, 40)
                .foregroundColor(.white)

                // --- "Continue to Video" Button (replace with your next step)
                
                SecondaryActionButton(title: "Continue to Videos") {
                    router.goToVideoPreview()
                }.padding(.horizontal, 30)

                
                // --- "Regenerate Images" Button
                Button("Regenerate Images") {
                    viewModel.generateImages(for: viewModel.currentSceneIndex)
                }
                .foregroundColor(.white)

                Spacer()
            }
        }
        .onAppear {
            viewModel.loadScenes(from: script)
        }
    }
}

// MARK: - Preview
#Preview {
    ImageScreen(script: """
    The human eye is one of the most extraordinary organs in the body.
    It captures light, interprets color, and helps us understand the world around us.
    Behind every blink is a complex system — the cornea, lens, and retina all working together like a perfect machine.
    """).withRouter()
}
