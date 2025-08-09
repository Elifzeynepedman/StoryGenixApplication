import SwiftUI
import AVKit
import Combine

struct VideoPreviewScreen: View {
    let project: VideoProject
    @StateObject private var viewModel = VideoPreviewViewModel()
    @State private var player = AVPlayer()
    @State private var showWarning = false

    @Environment(Router.self) private var router
    @EnvironmentObject private var projectViewModel: ProjectsViewModel

    var body: some View {
        ZStack {
            // ✅ Background
            Color("Background")
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
                    Text("Step 4 of 4")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.top, 20)

                // ✅ Scrollable Content
                ScrollView(showsIndicators: false) {
                    if viewModel.scenes.indices.contains(viewModel.currentSceneIndex) {
                        let currentScene = viewModel.scenes[viewModel.currentSceneIndex]

                        VStack(spacing: 16) {
                            
                            Text("Scene \(viewModel.currentSceneIndex + 1) of \(viewModel.scenes.count)")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                            
                            // ✅ Scene Description
                            Text(currentScene.sceneText)
                                .font(.headline)
                                .foregroundColor(.white)

                            // ✅ Prompt Editor
                            TextEditor(text: Binding(
                                get: { currentScene.prompt },
                                set: { newValue in
                                    viewModel.updatePrompt(for: viewModel.currentSceneIndex, newPrompt: newValue)
                                }
                            ))
                            .scrollContentBackground(.hidden)
                            .frame(height: 80)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.25))
                            .clipShape(RoundedRectangle(cornerRadius: 14))

                            // ✅ Generate or Regenerate Button
                            if currentScene.videoURL == nil {
                                PrimaryGradientButton(
                                    title: "Generate Video",
                                    isLoading: viewModel.isSceneLoading[viewModel.currentSceneIndex] ?? false
                                ){
                                    if let backendId = project.backendId, !backendId.isEmpty {
                                        viewModel.generateVideo(for: viewModel.currentSceneIndex, projectId: backendId)
                                    } else {
                                        print("❌ Missing backendId.")
                                    }
                                }
                            } else {
                                Button {
                                    if let backendId = project.backendId {
                                        viewModel.generateVideo(for: viewModel.currentSceneIndex, projectId: backendId)
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "arrow.clockwise")
                                        Text("Regenerate Video")
                                    }
                                    .foregroundColor(.white)
                                    .padding(.vertical, 6)
                                }
                            }

                            // ✅ Video Preview
                            if let videoURL = currentScene.videoURL {
                                VideoPlayer(player: player)
                                    .frame(height: 220)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .shadow(radius: 6)
                                    .onReceive(Just(videoURL)) { url in
                                        let item = AVPlayerItem(url: url)
                                        player.replaceCurrentItem(with: item)

                                        // ✅ Play after asset is ready
                                        item.asset.loadValuesAsynchronously(forKeys: ["playable"]) {
                                            DispatchQueue.main.async {
                                                if item.asset.isPlayable {
                                                    player.play()
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

                        // ✅ Navigation Buttons
                        if currentScene.videoURL != nil {
                            HStack(spacing: 16) {
                                if viewModel.currentSceneIndex > 0 {
                                    Button("← Previous") { viewModel.currentSceneIndex -= 1 }
                                }
                                Spacer()
                                if viewModel.currentSceneIndex < viewModel.scenes.count - 1 {
                                    Button("Next →") {
                                        if currentScene.videoURL == nil {
                                            withAnimation { showWarning = true }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { showWarning = false }
                                        } else {
                                            viewModel.currentSceneIndex += 1
                                        }
                                    }
                                } else {
                                    PrimaryGradientButton(title: "Continue to Final", isLoading: false) {
                                        var updated = project
                                        updated.thumbnail = viewModel.scenes.first?.previewImage ?? "defaultThumbnail"
                                        updated.scenes = viewModel.scenes
                                        updated.progressStep = .completed
                                        updated.isCompleted = true
                                        updated.currentSceneIndex = viewModel.currentSceneIndex

                                        
                                        projectViewModel.upsertAndNavigate(updated) {
                                            router.goToVideoComplete(project: $0)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)
                        }
                    }
                }
            }
            .padding(.horizontal)

            // ✅ Warning Toast
            if showWarning {
                VStack {
                    Spacer()
                    Text("Please generate the video to continue")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.bottom, 40)
                        .transition(.opacity)
                }
            }
        }
        .onAppear {
            // ✅ Load video scenes
            viewModel.loadScenes(from: project.scenes)

            // ✅ Draft project update
            let draft = VideoProject(
                id: project.id,
                backendId: project.backendId,
                title: project.title,
                script: project.script,
                thumbnail: viewModel.scenes.first?.previewImage ?? "defaultThumbnail",
                scenes: viewModel.scenes,
                voiceId: project.voiceId,
                audioURL: project.audioURL,
                selectedImageIndices: project.selectedImageIndices,
                videoURL: project.videoURL,
                isCompleted: false,
                progressStep: .video,
                currentSceneIndex: viewModel.currentSceneIndex
            )


            projectViewModel.upsertAndNavigate(draft) { _ in }
        }
    }
}
