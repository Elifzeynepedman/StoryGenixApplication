//
//  ImageViewModel.swift
//  StoryGenixApp
//
//  Created by Elif Edman on 29.06.2025.
//

import Foundation
import Combine

class ImageViewModel: ObservableObject {
    @Published var scenes: [ImageScene] = []
    @Published var currentSceneIndex = 0
    @Published var isLoading = false
    @Published var aspectOptions = ["1:1", "9:16", "16:9"]
    @Published var selectedAspect = "1:1"
    @Published var selectedImageIndices: [Int?] = []

    // MARK: - Load Script into Scenes
    func loadScenes(from script: String, existingSelections: [Int?] = []) {
        let lines = script
            .components(separatedBy: "\n")
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

        self.scenes = lines.map { line in
            let prompt = convertScriptLineToLeonardoPrompt(line)
            return ImageScene(sceneText: line, prompt: prompt)
        }

        // Initialize or restore selection
        if existingSelections.count == scenes.count {
            self.selectedImageIndices = existingSelections
            for (i, index) in existingSelections.enumerated() {
                if let idx = index {
                    scenes[i].selectedImage = "Efes\(idx + 1)"
                }
            }
            self.currentSceneIndex = existingSelections.firstIndex(where: { $0 == nil }) ?? 0
        } else {
            self.selectedImageIndices = Array(repeating: nil, count: scenes.count)
            self.currentSceneIndex = 0
        }
    }

    func convertScriptLineToLeonardoPrompt(_ line: String) -> String {
        return "Highly detailed cinematic illustration of: \(line.lowercased()). Sharp lighting, depth, and atmosphere."
    }

    func generateImages(for index: Int) {
        guard scenes.indices.contains(index) else { return }
        isLoading = true
        scenes[index].generatedImages = []

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.scenes[index].generatedImages = ["Efes1", "Efes2", "Efes3", "Efes4"]
            self.isLoading = false
        }
    }

    func selectImage(_ image: String, for index: Int) {
        guard scenes.indices.contains(index) else { return }
        scenes[index].selectedImage = image

        // Save index
        if let idx = scenes[index].generatedImages.firstIndex(of: image) {
            selectedImageIndices[index] = idx
        }
    }

    func updatePrompt(for index: Int, newPrompt: String) {
        guard scenes.indices.contains(index) else { return }
        scenes[index].prompt = newPrompt
    }
}
