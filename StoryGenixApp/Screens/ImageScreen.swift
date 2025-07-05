import SwiftUI

struct ImageScreen: View {
    let project: VideoProject

    @StateObject private var viewModel = ImageViewModel()
    @State private var showSelectionWarning = false
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
                            sceneSection(for: viewModel.scenes[viewModel.currentSceneIndex])
                        }

                        Spacer(minLength: 40)
                    }
                }
            }
        }
        .onAppear {
            let scriptLines = project.script
                .components(separatedBy: "\n")
                .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

            let restoredSelections: [Int?] = scriptLines.enumerated().map { index, _ in
                project.selectedImageIndices[index]
            }

            viewModel.loadScenes(from: project.script, existingSelections: restoredSelections)

            if let index = project.currentSceneIndex {
                viewModel.currentSceneIndex = index
            }
        }
    }

    // MARK: - Scene Section

    @ViewBuilder
    private func sceneSection(for currentScene: ImageScene) -> some View {
        VStack(spacing: 20) {
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
                generateButtonTitle: currentScene.generatedImages.isEmpty ? "Generate Images" : "Regenerate Images"
            )

            if showSelectionWarning {
                Text("Please select an image before continuing.")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.red)
                    .transition(.opacity)
                    .padding(.top, -6)
            }

            if !currentScene.generatedImages.isEmpty {
                imageGrid(for: currentScene)
                sceneNavigationButtons(for: currentScene)
            }
        }
    }

    // MARK: - Image Grid

    @ViewBuilder
    private func imageGrid(for currentScene: ImageScene) -> some View {
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

                    var updated = project
                    if let index = viewModel.scenes[viewModel.currentSceneIndex].generatedImages.firstIndex(of: imageName) {
                        updated.selectedImageIndices[viewModel.currentSceneIndex] = index
                    }
                    updated.currentSceneIndex = viewModel.currentSceneIndex
                    projectViewModel.updateProject(updated)
                }
            }
        }
        .padding(.horizontal, 30)
    }

    // MARK: - Navigation Buttons

    @ViewBuilder
    private func sceneNavigationButtons(for currentScene: ImageScene) -> some View {
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
            }.disabled(viewModel.currentSceneIndex >= viewModel.scenes.count - 1)
        }
        .padding(.horizontal, 40)
        .foregroundColor(.white)

        // MARK: - Continue to Videos Button in sceneNavigationButtons

        if viewModel.currentSceneIndex == viewModel.scenes.count - 1 {
            SecondaryActionButton(title: "Continue to Videos") {
                var updated = project
                updated.progressStep = 3
                updated.currentSceneIndex = viewModel.currentSceneIndex

                projectViewModel.upsertAndNavigate(updated) { router.goToVideoPreview(project: $0) }
            }
            .padding(.horizontal, 30)
        }
    }
}
