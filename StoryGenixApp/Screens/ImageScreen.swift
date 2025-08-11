import SwiftUI

struct ImageScreen: View {
    let project: VideoProject
    @StateObject private var viewModel = ImageViewModel()

    @State private var showSelectionWarning = false
    @State private var fullscreenImageURL: String?
    @State private var isPromptExpanded = false

    @Environment(Router.self) private var router
    @EnvironmentObject private var projectViewModel: ProjectsViewModel

    private var currentAspectRatio: CGFloat {
        switch viewModel.selectedAspect {
        case "16:9": return 16.0 / 9.0
        case "9:16": return 9.0 / 16.0
        default: return 1.0
        }
    }

    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()

            VStack(spacing: 20) {
                header
                SegmentedToggle(options: viewModel.aspectOptions, selected: $viewModel.selectedAspect)
                    .padding(.horizontal, 20)

                ScrollView(showsIndicators: false) {
                    if let currentScene = currentScene {
                        sceneCard(currentScene)
                    } else {
                        loadingState
                    }
                }
                .padding(.horizontal)
            }

            if showSelectionWarning { selectionWarning }
            if let url = fullscreenImageURL { fullscreenViewer(url: url) }
            if isPromptExpanded { promptModal }
        }
        .onAppear { viewModel.loadFromScenes(project.scenes) }
        .onChange(of: viewModel.selectedAspect) { _ in clearCurrentSceneImages() }
        .safeAreaInset(edge: .bottom) { footerControls }
    }

    // MARK: - UI Components

    private var header: some View {
        VStack(spacing: 6) {
            Text("My AI Director").font(.system(size: 36, weight: .bold)).foregroundColor(.white)
            Text("Generate Images").font(.title2.bold()).foregroundColor(.white.opacity(0.9))
            Text("Step 3 of 4").font(.system(size: 12)).foregroundColor(.white.opacity(0.7))
        }
        .padding(.top, 20)
    }

    private var loadingState: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading scenes…").foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, minHeight: 220)
    }

    private var selectionWarning: some View {
        VStack {
            Spacer()
            Text("Please select an image to continue")
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.bottom, 40)
                .transition(.opacity)
        }
    }

    private func fullscreenViewer(url: String) -> some View {
        GeometryReader { geo in
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
                            .frame(
                                maxWidth: geo.size.width,
                                maxHeight: min(geo.size.height, geo.size.width * (currentAspectRatio > 1 ? 0.9 : 1.8))
                            )
                            .background(Color.black)
                            .ignoresSafeArea()
                    case .failure:
                        Text("Failed to load image").foregroundColor(.white)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { fullscreenImageURL = nil }
            .transition(.opacity)
        }
    }


    private var promptModal: some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()
                .onTapGesture { withAnimation(.easeOut) { isPromptExpanded = false } }

            VStack(spacing: 16) {
                HStack {
                    Text("Edit Prompt").font(.headline).foregroundColor(.white)
                    Spacer()
                    Button {
                        withAnimation(.easeOut) { isPromptExpanded = false }
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Circle())
                    }
                }

                if let binding = currentPromptBinding {
                    TextEditor(text: binding)
                        .scrollContentBackground(.hidden)
                        .foregroundColor(.white)
                        .padding(12)
                        .frame(minHeight: 180, maxHeight: 340)
                        .background(Color.black.opacity(0.18))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                HStack {
                    Spacer()
                    Button {
                        withAnimation(.easeOut) { isPromptExpanded = false }
                    } label: {
                        Text("Done")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            .padding(18)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .frame(maxWidth: 720)
        }
    }

    private func sceneCard(_ currentScene: ImageScene) -> some View {
        VStack(spacing: 16) {
            Text("Scene \(viewModel.currentSceneIndex + 1) of \(viewModel.scenes.count)")
                .font(.subheadline).foregroundColor(.white.opacity(0.8))

            Text(currentScene.sceneText)
                .font(.headline).foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            promptEditor

            if currentScene.generatedImages.isEmpty {
                PrimaryGradientButton(
                    title: "Generate Images",
                    isLoading: viewModel.isSceneLoading[viewModel.currentSceneIndex] ?? false
                ) {
                    if let backendId = project.backendId, !backendId.isEmpty {
                        viewModel.generateImagesForCurrentScene(projectId: backendId)
                    }
                }
            } else {
                regenerateButton
                thumbnailsGrid(currentScene)
            }
        }
        .padding()
        .background(Color.black.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var promptEditor: some View {
        ZStack(alignment: .topTrailing) {
            if let binding = currentPromptBinding {
                TextEditor(text: binding)
                    .scrollContentBackground(.hidden)
                    .frame(height: 88)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.black.opacity(0.25))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            Button { withAnimation(.easeInOut) { isPromptExpanded = true } } label: {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.white.opacity(0.15))
                    .clipShape(Circle())
                    .padding(8)
            }
        }
    }

    private var regenerateButton: some View {
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
    }

    private func thumbnailsGrid(_ currentScene: ImageScene) -> some View {
        let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]
        return LazyVGrid(columns: columns, spacing: 14) {
            ForEach(currentScene.generatedImages, id: \.self) { img in
                SquareThumbnailView(
                    imageURL: img,
                    isSelected: currentScene.selectedImage == img,
                    onTap: { fullscreenImageURL = img },
                    onSelect: { viewModel.selectImage(img, for: viewModel.currentSceneIndex) }
                )
            }
        }
        .padding(.top, 10)
    }


    private var footerControls: some View {
        Group {
            if let currentScene = currentScene {
                navigationControls(for: currentScene)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
            }
        }
    }

    // MARK: - Helpers
    private func navigationControls(for currentScene: ImageScene) -> some View {
        HStack(spacing: 16) {
            Button {
                viewModel.currentSceneIndex = max(0, viewModel.currentSceneIndex - 1)
            } label: {
                Text("← Previous")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .opacity(viewModel.currentSceneIndex > 0 ? 1 : 0.5)
            }
            .disabled(viewModel.currentSceneIndex == 0)

            Spacer()

            if viewModel.currentSceneIndex < viewModel.scenes.count - 1 {
                Button {
                    guard !(currentScene.generatedImages.isEmpty || currentScene.selectedImage == nil) else {
                        showWarning()
                        return
                    }
                    viewModel.currentSceneIndex += 1
                } label: {
                    Text("Next →")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
            } else {
                PrimaryGradientButton(title: "Continue to Video", isLoading: false) {
                    guard !(currentScene.generatedImages.isEmpty || currentScene.selectedImage == nil) else {
                        showWarning()
                        return
                    }

                    var updated = project
                    updated.progressStep = .video
                    updated.selectedImageIndices = viewModel.selectedImageIndices.enumerated()
                        .reduce(into: [:]) { dict, tuple in
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
    }

    private func clearCurrentSceneImages() {
        guard let idx = safeCurrentIndex else { return }
        viewModel.scenes[idx].generatedImages = []
        viewModel.scenes[idx].selectedImage = nil
    }

    private func showWarning() {
        withAnimation { showSelectionWarning = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { showSelectionWarning = false }
    }

    private var safeCurrentIndex: Int? {
        guard viewModel.scenes.indices.contains(viewModel.currentSceneIndex) else { return nil }
        return viewModel.currentSceneIndex
    }

    private var currentScene: ImageScene? {
        guard let idx = safeCurrentIndex else { return nil }
        return viewModel.scenes[idx]
    }

    private var currentPromptBinding: Binding<String>? {
        guard let idx = safeCurrentIndex else { return nil }
        return Binding(
            get: { viewModel.scenes[idx].prompt },
            set: { viewModel.updatePrompt(for: idx, newPrompt: $0) }
        )
    }
}
