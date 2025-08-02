//
//  VideoPreviewViewModel.swift
//  StoryGenix
//
//  Created by Elif Edman on 29.06.2025.
//

import Foundation
import Combine

class VideoPreviewViewModel: ObservableObject {
    @Published var scenes: [VideoScene] = []
    @Published var currentSceneIndex = 0
    @Published var isLoading = false

    func loadScenes(script: String, descriptions: [String], klingPrompts: [String], existingSelections: [Int?] = []) {
        self.scenes = descriptions.enumerated().map { index, desc in
            let prompt = index < klingPrompts.count ? klingPrompts[index] : "Default Kling animation instruction for \(desc)"
            return VideoScene(sceneText: desc, prompt: prompt, videoURL: nil, previewImage: "defaultThumbnail")
        }
    }
    
    func updatePrompt(for index: Int, newPrompt: String) {
        guard scenes.indices.contains(index) else { return }
        scenes[index].prompt = newPrompt
    }

    func generateVideo(for index: Int, projectId: String) {
        guard scenes.indices.contains(index) else { return }
        isLoading = true
        
        Task {
            do {
                // Start video generation
                let response = try await ApiService.shared.startVideoGeneration(
                    projectId: projectId,
                    videoScenes: scenes.map { ["text": $0.sceneText, "imageUrl": $0.previewImage ?? ""] },
                    audioFile: "mock-audio.mp3", // Replace with real audio path later
                    sceneAlignment: "sequential"
                )
                print("✅ Video job started: \(response.jobId)")
                
                // Poll until status is completed
                var videoUrl: String? = nil
                while videoUrl == nil {
                    try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                    let statusResponse = try await ApiService.shared.getVideoStatus(projectId: projectId)
                    print("📡 Status: \(statusResponse.status)")
                    
                    if statusResponse.status == "completed" {
                        videoUrl = statusResponse.finalVideoUrl
                    }
                }
                
                DispatchQueue.main.async {
                    if let urlString = videoUrl, let url = URL(string: urlString) {
                        self.scenes[index].videoURL = url
                    }
                    self.isLoading = false
                }
            } catch {
                print("❌ Error generating video: \(error)")
                DispatchQueue.main.async { self.isLoading = false }
            }
        }
    }

}
