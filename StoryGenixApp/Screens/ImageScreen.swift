import SwiftUI

struct ImageScreen: View {
    let script: String
    let topic: String

    @StateObject private var viewModel = ImageViewModel()
    @State private var showSelectionWarning = false
    @State private var projectID = UUID()

    @Environment(Router.self) private var router
    @EnvironmentObject private var projectViewModel: ProjectsViewModel

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

                Text("Generate Your Images")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        SegmentedToggle(
                            options: viewModel.aspectOptions,
                            selected: $viewModel.selectedAspect
                        )
                        .padding(.horizontal, 35)

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
                                    viewModel.generateImages(for: viewModel.currentSceneIndex)
                                },
                                onPrevious: {
                                    if viewModel.currentSceneIndex > 0 {
                                        viewModel.currentSceneIndex -= 1
                                        showSelectionWarning = false
                                    }
                                },
                                onNext: {
                                    if currentScene.selectedImage == nil {
                                        withAnimation { showSelectionWarning = true }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            withAnimation { showSelectionWarning = false }
                                        }
                                    } else if viewModel.currentSceneIndex < viewModel.scenes.count - 1 {
                                        viewModel.currentSceneIndex += 1
                                    }
                                },
                                canGoPrevious: viewModel.currentSceneIndex > 0,
                                canGoNext: viewModel.currentSceneIndex < viewModel.scenes.count - 1,
                                isLoading: viewModel.isLoading,
                                shouldShowNavigation: !currentScene.generatedImages.isEmpty,
                                generateButtonTitle: "Generate Images"
                            )

                            if showSelectionWarning {
                                Text("Please select an image before continuing.")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.red)
                                    .transition(.opacity)
                                    .padding(.top, -6)
                            }

                            if !currentScene.generatedImages.isEmpty {
                                LazyVGrid(columns: [GridItem(), GridItem()], spacing: 16) {
                                    ForEach(currentScene.generatedImages, id: \.self) { imageName in
                                        ZStack(alignment: .topTrailing) {
                                            Image(imageName)
                                                .resizable()
                                                .aspectRatio(1, contentMode: .fill)
                                                .frame(width: 170, height: 170)
                                                .clipped()
                                                .cornerRadius(12)

                                            if currentScene.selectedImage == imageName {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.white)
                                                    .background(Circle().fill(Color.blue))
                                                    .padding(6)
                                            }
                                        }
                                        .onTapGesture {
                                            viewModel.selectImage(imageName, for: viewModel.currentSceneIndex)
                                        }
                                    }
                                }
                                .padding(.horizontal, 30)

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
                                        if currentScene.selectedImage == nil {
                                            withAnimation { showSelectionWarning = true }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                withAnimation { showSelectionWarning = false }
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
                                    SecondaryActionButton(title: "Continue to Videos") {
                                        router.goToVideoPreview(script: script, topic: topic)
                                    }
                                    .padding(.horizontal, 30)
                                }

                                Button("Regenerate Images") {
                                    viewModel.generateImages(for: viewModel.currentSceneIndex)
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

            let draft = VideoProject(
                id: projectID,
                title: topic,
                script: script,
                thumbnail: viewModel.scenes.first?.selectedImage ?? "defaultThumbnail",
                scenes: viewModel.scenes.map {
                    VideoScene(
                        id: $0.id,
                        sceneText: $0.sceneText,
                        prompt: $0.prompt,
                        videoURL: nil,
                        previewImage: $0.selectedImage ?? "defaultThumbnail"
                    )
                },
                isCompleted: false,
                progressStep: 2
            )

            if let index = projectViewModel.allProjects.firstIndex(where: { $0.id == draft.id }) {
                projectViewModel.updateProject(draft)
            } else {
                projectViewModel.addProject(draft)
            }
        }
    }
}
