//
//  VideoPreviewViewModel.swift
//  StoryGenix
//
//  Created by Elif Edman on 29.06.2025.
//

import Foundation

@MainActor
class VideoPreviewViewModel: ObservableObject {
    @Published var scenes: [VideoScene] = []
    @Published var currentSceneIndex = 0
    @Published var isSceneLoading: [Int: Bool] = [:]   // ✅ Track loading state per scene
    @Published var errorMessage: String? = nil
    @Published var finalVideoURL: URL? = nil           // ✅ Track combined video URL if needed later

    // ✅ Load scenes from project data
    func loadScenes(script: String, descriptions: [String], klingPrompts: [String], existingSelections: [Int?] = []) {
        self.scenes = descriptions.enumerated().map { index, desc in
            let prompt = index < klingPrompts.count ? klingPrompts[index] : "Default Kling animation for \(desc)"
            return VideoScene(sceneText: desc, prompt: prompt, videoURL: nil, previewImage: "defaultThumbnail")
        }
    }

    // ✅ Update Kling prompt for a scene
    func updatePrompt(for index: Int, newPrompt: String) {
        guard scenes.indices.contains(index) else { return }
        scenes[index].prompt = newPrompt
    }

    // ✅ Generate video for a specific scene
    func generateVideo(for index: Int, projectId: String) {
        guard scenes.indices.contains(index) else { return }
        guard !projectId.isEmpty else {
            errorMessage = "Missing Project ID."
            return
        }

        isSceneLoading[index] = true
        errorMessage = nil

        Task {
            do {
                // ✅ Start video generation job
                let response = try await ApiService.shared.startVideoGeneration(
                    projectId: projectId,
                    videoScenes: scenes.map { ["text": $0.sceneText, "imageUrl": $0.previewImage ?? ""] },
                    audioFile: "mock-audio.mp3", // Replace with actual audio file path
                    sceneAlignment: "sequential"
                )

                print("✅ Video job started: \(response.jobId)")

                // ✅ Poll until the backend reports "completed"
                var videoUrl: String? = nil
                while videoUrl == nil {
                    try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
                    let status = try await ApiService.shared.getVideoStatus(projectId: projectId)
                    print("📡 Video status: \(status.status)")

                    if status.status == "completed" {
                        videoUrl = status.finalVideoUrl
                    }
                }

                if let urlString = videoUrl, let url = URL(string: urlString) {
                    scenes[index].videoURL = url
                    finalVideoURL = url
                    print("✅ Final video URL: \(url)")
                } else {
                    errorMessage = "Failed to retrieve final video URL."
                }

            } catch {
                print("❌ Error generating video: \(error.localizedDescription)")
                errorMessage = "Failed to generate video. Please try again."
            }
            isSceneLoading[index] = false
        }
    }
}
