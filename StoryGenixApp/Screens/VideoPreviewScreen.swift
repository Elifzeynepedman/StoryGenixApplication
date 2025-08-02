import SwiftUI
import AVKit
import Combine

struct VideoPreviewScreen: View {
    let project: VideoProject

    @StateObject private var viewModel = VideoPreviewViewModel()
    @State private var player = AVPlayer()
    @State private var showSelectionWarning = false

    @Environment(Router.self) private var router
    @EnvironmentObject private var projectViewModel: ProjectsViewModel

    var body: some View {
        ZStack {
            // ✅ Background
            Image("BackgroundImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // ✅ Header
                VStack(spacing: 6) {
                    Text("My AI Director")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    Text("Preview Your Video")
                        .font(.title2.bold())
                        .foregroundColor(.white.opacity(0.9))
                    Text("Step 4 out of 4")
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.top, 40)

                // ✅ Scrollable Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        if viewModel.scenes.indices.contains(viewModel.currentSceneIndex) {
                            let currentScene = viewModel.scenes[viewModel.currentSceneIndex]

                            sceneSection(for: currentScene)
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal)
                }
            }

            // ✅ Floating Toast Alert
            if showSelectionWarning {
                VStack {
                    Spacer()
                    Text("Please generate the video to continue")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                        .padding(.bottom, 40)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.easeInOut, value: showSelectionWarning)
            }
        }
        .onAppear {
            // ✅ Load scenes and update draft
            viewModel.loadScenes(
                script: project.script,
                descriptions: project.sceneDescriptions,
                klingPrompts: project.klingPrompts,
                existingSelections: project.selectedImageIndices.map { $0.value }
            )

            let draft = VideoProject(
                id: project.id,
                title: project.title,
                script: project.script,
                thumbnail: viewModel.scenes.first?.previewImage ?? "defaultThumbnail",
                scenes: viewModel.scenes,
                sceneDescriptions: project.sceneDescriptions,
                imagePrompts: project.imagePrompts,
                klingPrompts: project.klingPrompts,
                isCompleted: false,
                progressStep: 3
            )

            if projectViewModel.allProjects.contains(where: { $0.id == draft.id }) {
                projectViewModel.updateProject(draft)
            } else {
                projectViewModel.addProject(draft)
            }
        }
    }

    @ViewBuilder
    private func sceneSection(for currentScene: VideoScene) -> some View {
        VStack(spacing: 16) {
            // ✅ Unified Glass Panel
            VStack(alignment: .leading, spacing: 14) {
                // Scene info
                Text("Scene \(viewModel.currentSceneIndex + 1) of \(viewModel.scenes.count)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))

                Text(currentScene.sceneText)
                    .font(.headline)
                    .foregroundColor(.white)

                // Kling prompt editor
                TextEditor(text: Binding(
                    get: { currentScene.prompt },
                    set: { newPrompt in
                        viewModel.updatePrompt(for: viewModel.currentSceneIndex, newPrompt: newPrompt)
                    }
                ))
                .scrollContentBackground(.hidden)
                .frame(height: 80)
                .foregroundColor(.white)
                .padding(8)
                .background(Color.black.opacity(0.25))
                .clipShape(RoundedRectangle(cornerRadius: 14))

                // Generate / Regenerate button
                if currentScene.videoURL == nil {
                    PrimaryGradientButton(title: "Generate Video", isLoading: viewModel.isLoading) {
                        viewModel.generateVideo(for: viewModel.currentSceneIndex, projectId: project.backendId ?? "")
                    }

                } else {
                    HStack {
                        Spacer()
                        Button {
                            viewModel.generateVideo(for: viewModel.currentSceneIndex, projectId: project.backendId ?? "")
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.clockwise")
                                Text("Regenerate Video")
                            }
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                        }
                        Spacer()
                    }
                }

                // ✅ Video Preview Inside the Same Box
                if let videoURL = currentScene.videoURL {
                    VideoPlayer(player: player)
                        .frame(height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(radius: 6)
                        .onReceive(Just(videoURL)) { url in
                            player.replaceCurrentItem(with: AVPlayerItem(url: url))
                            player.play()
                        }
                }
            }
            .padding()
            .background(
                ZStack {
                    Color.black.opacity(0.25)
                    LinearGradient(
                        colors: [
                            Color("BackgroundGradientDark").opacity(0.15),
                            Color("BackgroundGradientPurple").opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)

            // ✅ Navigation + Continue
            if currentScene.videoURL != nil {
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        if viewModel.currentSceneIndex > 0 {
                            Button(action: { viewModel.currentSceneIndex -= 1 }) {
                                Text("← Previous")
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 20)
                                    .background(Color.white.opacity(0.1))
                                    .clipShape(Capsule())
                                    .foregroundColor(.white)
                            }
                        }

                        Spacer()

                        if viewModel.currentSceneIndex < viewModel.scenes.count - 1 {
                            Button(action: {
                                if currentScene.videoURL == nil {
                                    withAnimation { showSelectionWarning = true }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        withAnimation { showSelectionWarning = false }
                                    }
                                } else {
                                    viewModel.currentSceneIndex += 1
                                }
                            }) {
                                Text("Next →")
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 20)
                                    .background(Color.white.opacity(0.1))
                                    .clipShape(Capsule())
                                    .foregroundColor(.white)
                            }
                        }
                    }

                    if viewModel.currentSceneIndex == viewModel.scenes.count - 1 {
                        PrimaryGradientButton(title: "Continue to Final", isLoading: false) {
                            var updated = VideoProject(
                                id: project.id,
                                title: project.title,
                                script: project.script,
                                thumbnail: viewModel.scenes.first?.previewImage ?? "defaultThumbnail",
                                scenes: viewModel.scenes,
                                sceneDescriptions: project.sceneDescriptions,
                                imagePrompts: project.imagePrompts,
                                klingPrompts: project.klingPrompts,
                                isCompleted: true,
                                progressStep: 4
                            )
                            updated.currentSceneIndex = viewModel.currentSceneIndex

                            projectViewModel.upsertAndNavigate(updated) {
                                router.goToVideoComplete(project: $0)
                            }
                        }
                        .padding(.top, 10)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

}
