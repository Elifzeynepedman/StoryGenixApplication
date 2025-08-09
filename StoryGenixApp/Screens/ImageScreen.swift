import SwiftUI

struct ImageScreen: View {
    let project: VideoProject
    @StateObject private var viewModel = ImageViewModel()
    @State private var showSelectionWarning = false
    @State private var fullscreenImageURL: String?

    @Environment(Router.self) private var router
    @EnvironmentObject private var projectViewModel: ProjectsViewModel

    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 20) {
                header

                SegmentedToggle(options: viewModel.aspectOptions, selected: $viewModel.selectedAspect)
                    .padding(.horizontal, 20)

                ScrollView(showsIndicators: false) {
                    if viewModel.scenes.indices.contains(viewModel.currentSceneIndex) {
                        let currentScene = viewModel.scenes[viewModel.currentSceneIndex]
                        sceneCard(currentScene)
                        navigationControls(for: currentScene)
                    }
                }
            }
            .padding(.horizontal)

            if showSelectionWarning {
                VStack {
                    Spacer()
                    Text("Please select an image to continue")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.bottom, 40)
                        .transition(.opacity)
                }
            }

            // ✅ Fullscreen image viewer
            if let url = fullscreenImageURL {
                ZStack {
                    Color.black.ignoresSafeArea()
                    AsyncImage(url: URL(string: url)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView().scaleEffect(2)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.black)
                                .ignoresSafeArea()
                        case .failure:
                            Text("Failed to load image")
                                .foregroundColor(.white)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                .contentShape(Rectangle()) // full screen tappable
                .onTapGesture {
                    fullscreenImageURL = nil
                }
            }

        }
        .onAppear {
            viewModel.loadFromScenes(project.scenes)
        }
    }

    private var header: some View {
        VStack(spacing: 6) {
            Text("My AI Director")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
            Text("Generate Images")
                .font(.title2.bold())
                .foregroundColor(.white.opacity(0.9))
            Text("Step 3 of 4")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.top, 20)
    }

    private func sceneCard(_ currentScene: ImageScene) -> some View {
        VStack(spacing: 16) {
            Text("Scene \(viewModel.currentSceneIndex + 1) of \(viewModel.scenes.count)")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))

            Text(currentScene.sceneText)
                .font(.headline)
                .foregroundColor(.white)

            TextEditor(text: Binding(
                get: { currentScene.prompt },
                set: { viewModel.updatePrompt(for: viewModel.currentSceneIndex, newPrompt: $0) }
            ))
            .scrollContentBackground(.hidden)
            .frame(height: 80)
            .foregroundColor(.white)
            .padding(8)
            .background(Color.black.opacity(0.25))
            .clipShape(RoundedRectangle(cornerRadius: 14))

            if currentScene.generatedImages.isEmpty {
                PrimaryGradientButton(
                    title: "Generate Images",
                    isLoading: viewModel.isSceneLoading[viewModel.currentSceneIndex] ?? false
                ) {
                    if let backendId = project.backendId, !backendId.isEmpty {
                        viewModel.generateImagesForCurrentScene(projectId: backendId)
                    } else {
                        print("❌ Missing backendId.")
                    }
                }
            } else {
                Button {
                    if let backendId = project.backendId, !backendId.isEmpty {
                        viewModel.generateImagesForCurrentScene(projectId: backendId)
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                        Text("Regenerate Images")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.vertical, 6)
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(currentScene.generatedImages, id: \.self) { img in
                        ZStack(alignment: .topTrailing) {
                            Button {
                                fullscreenImageURL = img
                            } label: {
                                AsyncImage(url: URL(string: img)) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }

                            Button {
                                viewModel.selectImage(img, for: viewModel.currentSceneIndex)
                            } label: {
                                Circle()
                                    .fill(currentScene.selectedImage == img ? Color.green : Color.black.opacity(0.3))
                                    .frame(width: 26, height: 26)
                                    .overlay {
                                        if currentScene.selectedImage == img {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.white)
                                        } else {
                                            Circle()
                                                .stroke(Color.white, lineWidth: 1)
                                        }
                                    }
                                    .padding(6)
                            }
                        }
                    }
                }
                .padding(.top, 10)
            }
        }
        .padding()
        .background(Color.black.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func navigationControls(for currentScene: ImageScene) -> some View {
        Group {
            if !currentScene.generatedImages.isEmpty {
                HStack(spacing: 16) {
                    if viewModel.currentSceneIndex > 0 {
                        Button("← Previous") {
                            viewModel.currentSceneIndex -= 1
                        }
                    }
                    Spacer()
                    if viewModel.currentSceneIndex < viewModel.scenes.count - 1 {
                        Button("Next →") {
                            if currentScene.selectedImage == nil {
                                withAnimation { showSelectionWarning = true }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    showSelectionWarning = false
                                }
                            } else {
                                viewModel.currentSceneIndex += 1
                            }
                        }
                    } else {
                        PrimaryGradientButton(title: "Continue to Video", isLoading: false) {
                            var updated = project
                            updated.progressStep = .video
                            updated.selectedImageIndices = viewModel.selectedImageIndices.enumerated().reduce(into: [:]) { dict, tuple in
                                if let selectedIndex = tuple.element {
                                    dict[tuple.offset] = selectedIndex
                                }
                            }
                            updated.currentSceneIndex = viewModel.currentSceneIndex
                            projectViewModel.upsertAndNavigate(updated) {
                                router.goToVideoPreview(project: $0)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
