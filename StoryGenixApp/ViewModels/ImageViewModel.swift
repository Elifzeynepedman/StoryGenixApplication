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

    var isSceneSelected: Bool {
        guard scenes.indices.contains(currentSceneIndex) else { return false }
        return scenes[currentSceneIndex].selectedImage != nil
    }

    // MARK: - Load Script and Create Scenes with Prompts
    func loadScenes(from script: String) {
        let lines = script
            .components(separatedBy: "\n")
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

        self.scenes = lines.map { line in
            let prompt = convertScriptLineToLeonardoPrompt(line)
            return ImageScene(sceneText: line, prompt: prompt)
        }
    }

    // MARK: - Convert Script to Leonardo Prompt
    func convertScriptLineToLeonardoPrompt(_ line: String) -> String {
        return """
        Highly detailed cinematic illustration of: \(line.lowercased()). Sharp lighting, depth, and atmosphere.. Sharp lighting, depth, and atmosphere.. Sharp lighting, depth, and atmosphere.. Sharp lighting, depth, and atmosphere. 
        """
    }

    // MARK: - Generate Mock Images
    func generateImages(for index: Int) {
        guard scenes.indices.contains(index) else { return }

        isLoading = true
        scenes[index].generatedImages = []

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.scenes[index].generatedImages = [
                "Efes1", "Efes2", "Efes3", "Efes4"
            ]
            self.isLoading = false
        }
    }

    // MARK: - Image Selection
    func selectImage(_ image: String, for index: Int) {
        guard scenes.indices.contains(index) else { return }
        scenes[index].selectedImage = image
    }

    // MARK: - Update Prompt
    func updatePrompt(for index: Int, newPrompt: String) {
        guard scenes.indices.contains(index) else { return }
        scenes[index].prompt = newPrompt
    }
}
