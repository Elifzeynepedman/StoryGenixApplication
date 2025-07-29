//
//  ImageViewModel.swift
//  StoryGenixApp
//
//  Created by Elif Edman on 29.06.2025.
//

import Foundation

class ImageViewModel: ObservableObject {
    @Published var scenes: [ImageScene] = []
    @Published var currentSceneIndex = 0
    @Published var isLoading = false
    @Published var aspectOptions = ["1:1", "9:16", "16:9"]
    @Published var selectedAspect = "1:1"
    @Published var selectedImageIndices: [Int?] = []

    /// Load scenes with script lines and LLM-generated scene details
    func loadScenes(from script: String, sceneDetails: [String], existingSelections: [Int?] = []) {
        let lines = script
            .components(separatedBy: "\n")
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

        self.scenes = lines.enumerated().map { index, line in
            let cleanLine = line.trimmingCharacters(in: .whitespaces)
            let detail = index < sceneDetails.count ? sceneDetails[index].trimmingCharacters(in: .whitespaces) : cleanLine

            let prompt = "Highly detailed cinematic illustration of: \(detail). Sharp lighting, vibrant colors, depth, photorealistic, ultra-realistic texture."
            
            return ImageScene(sceneText: cleanLine, prompt: prompt)
        }

        restoreSelections(existingSelections)
    }

    /// Restore previously selected images if any
    private func restoreSelections(_ existingSelections: [Int?]) {
        if existingSelections.count == scenes.count {
            self.selectedImageIndices = existingSelections
            for (i, index) in existingSelections.enumerated() {
                if let idx = index {
                    scenes[i].selectedImage = "Efes\(idx + 1)" // Mock placeholder
                }
            }
            self.currentSceneIndex = existingSelections.firstIndex(where: { $0 == nil }) ?? 0
        } else {
            self.selectedImageIndices = Array(repeating: nil, count: scenes.count)
            self.currentSceneIndex = 0
        }
    }

    /// Generate images (mock for now)
    func generateImages(for index: Int) {
        guard scenes.indices.contains(index) else { return }
        isLoading = true
        scenes[index].generatedImages = []

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.scenes[index].generatedImages = ["Efes1", "Efes2", "Efes3", "Efes4"]
            self.isLoading = false
        }
    }

    /// Select an image for the scene
    func selectImage(_ image: String, for index: Int) {
        guard scenes.indices.contains(index) else { return }
        scenes[index].selectedImage = image
        if let idx = scenes[index].generatedImages.firstIndex(of: image) {
            selectedImageIndices[index] = idx
        }
    }

    /// Update Leonardo prompt for a scene
    func updatePrompt(for index: Int, newPrompt: String) {
        guard scenes.indices.contains(index) else { return }
        scenes[index].prompt = newPrompt
    }
}
