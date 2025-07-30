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

    func generateVideo(for index: Int) {
        guard scenes.indices.contains(index) else { return }
        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if let path = Bundle.main.path(forResource: "EfesVideo", ofType: "mp4") {
                let url = URL(fileURLWithPath: path)
                self.scenes[index].videoURL = url
                print("✅ Video generated for scene \(index)")
            } else {
                print("❌ EfesVideo.mp4 not found in bundle.")
            }
            self.isLoading = false
        }
    }
}
