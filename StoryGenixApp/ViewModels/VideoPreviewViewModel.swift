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

    func loadScenes(from script: String) {
        let lines = script
            .components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

        self.scenes = lines.map {
            VideoScene(sceneText: $0, prompt: $0, videoURL: nil, previewImage: "PlaceholderImage")
        }
        self.currentSceneIndex = 0
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
                print("❌ Efes.mp4 not found in bundle.")
            }
            self.isLoading = false
        }
    }
}
