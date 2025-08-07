//
//  ImageViewModel.swift
//  StoryGenixApp
//
//  Created by Elif Edman on 29.06.2025.
//

import Foundation

@MainActor
class ImageViewModel: ObservableObject {
    @Published var scenes: [ImageScene] = []
    @Published var currentSceneIndex = 0
    @Published var isSceneLoading: [Int: Bool] = [:]  // ✅ Track loading state per scene
    @Published var aspectOptions = ["1:1", "9:16", "16:9"]
    @Published var selectedAspect = "1:1"
    @Published var selectedImageIndices: [Int?] = []

    // ✅ Load initial scenes
    func loadScenes(from script: String, sceneDetails: [String], prompts: [String], existingSelections: [Int?] = []) {
        self.scenes = sceneDetails.enumerated().map { index, desc in
            let prompt = index < prompts.count ? prompts[index] : "Highly detailed cinematic illustration of \(desc)"
            return ImageScene(sceneText: desc, prompt: prompt)
        }
        restoreSelections(existingSelections)
    }

    // ✅ Restore previously selected images (for resume functionality)
    private func restoreSelections(_ existingSelections: [Int?]) {
        if existingSelections.count == scenes.count {
            self.selectedImageIndices = existingSelections
            for (i, index) in existingSelections.enumerated() {
                if let idx = index, scenes[i].generatedImages.indices.contains(idx) {
                    scenes[i].selectedImage = scenes[i].generatedImages[idx]
                }
            }
            self.currentSceneIndex = existingSelections.firstIndex(where: { $0 == nil }) ?? 0
        } else {
            self.selectedImageIndices = Array(repeating: nil, count: scenes.count)
            self.currentSceneIndex = 0
        }
    }

    // ✅ Map aspect ratio from UI to backend keywords
    private func mapAspectRatio(_ aspect: String) -> String {
        switch aspect {
        case "1:1": return "square"
        case "9:16": return "portrait"
        case "16:9": return "landscape"
        default: return "square"
        }
    }

    // ✅ Generate images for the current scene only
    func generateImagesForCurrentScene(projectId: String) {
        guard !projectId.isEmpty else {
            print("❌ Error: Missing backend projectId")
            return
        }

        let index = currentSceneIndex
        guard scenes.indices.contains(index) else { return }

        isSceneLoading[index] = true
        scenes[index].generatedImages = []

        Task {
            do {
                let images = try await ApiService.shared.generateImagesForScene(
                    projectId: projectId,
                    sceneIndex: index,
                    prompt: scenes[index].prompt,
                    numImages: 4,
                    aspectRatio: mapAspectRatio(selectedAspect)
                )
                scenes[index].generatedImages = images
            } catch {
                print("❌ Error generating images for scene \(index): \(error.localizedDescription)")
            }
            isSceneLoading[index] = false
        }
    }

    // ✅ Select image for current scene
    func selectImage(_ image: String, for index: Int) {
        guard scenes.indices.contains(index) else { return }
        scenes[index].selectedImage = image
        if let idx = scenes[index].generatedImages.firstIndex(of: image) {
            selectedImageIndices[index] = idx
        }
    }

    // ✅ Update prompt for current scene
    func updatePrompt(for index: Int, newPrompt: String) {
        guard scenes.indices.contains(index) else { return }
        scenes[index].prompt = newPrompt
    }
    
    func loadFromScenes(_ videoScenes: [VideoScene]) {
        self.scenes = videoScenes.map {
            ImageScene(
                sceneText: $0.sceneText, // ← ✅ fixed
                prompt: $0.prompt        // ← ✅ fixed
            )
        }
        self.selectedImageIndices = Array(repeating: nil, count: self.scenes.count)
        self.currentSceneIndex = 0
    }

}
