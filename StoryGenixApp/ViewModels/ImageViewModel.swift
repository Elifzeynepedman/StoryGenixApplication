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
    
    func loadScenes(from script: String, sceneDetails: [String], prompts: [String], existingSelections: [Int?] = []) {
        self.scenes = sceneDetails.enumerated().map { index, desc in
            let prompt = index < prompts.count ? prompts[index] : "Highly detailed cinematic illustration of \(desc)"
            return ImageScene(sceneText: desc, prompt: prompt)
        }
        restoreSelections(existingSelections)
    }
    
    private func restoreSelections(_ existingSelections: [Int?]) {
        if existingSelections.count == scenes.count {
            self.selectedImageIndices = existingSelections
            for (i, index) in existingSelections.enumerated() {
                if let idx = index {
                    scenes[i].selectedImage = "Efes\(idx + 1)" // Placeholder for mock
                }
            }
            self.currentSceneIndex = existingSelections.firstIndex(where: { $0 == nil }) ?? 0
        } else {
            self.selectedImageIndices = Array(repeating: nil, count: scenes.count)
            self.currentSceneIndex = 0
        }
    }
    
    private func mapAspectRatio(_ aspect: String) -> String {
        switch aspect {
        case "1:1": return "square"
        case "9:16": return "portrait"
        case "16:9": return "landscape"
        default: return "square"
        }
    }
    
    func generateImagesForCurrentScene(projectId: String) {
        guard !projectId.isEmpty else {
            print("Error: Missing backend projectId")
            return
        }
        let index = currentSceneIndex
        guard scenes.indices.contains(index) else { return }

        // ✅ Clear any old images to ensure button works
        scenes[index].generatedImages = []

        isLoading = true

        Task {
            do {
                let response = try await ApiService.shared.generateImages(
                    projectId: projectId,
                    numImages: 4,
                    aspectRatio: mapAspectRatio(selectedAspect)
                )

                DispatchQueue.main.async {
                    if let firstSet = response.images.first {
                        self.scenes[index].generatedImages = firstSet
                    }
                    self.isLoading = false
                }

            } catch {
                print("Error generating images: \(error)")
                DispatchQueue.main.async { self.isLoading = false }
            }
        }
    }

    
    func selectImage(_ image: String, for index: Int) {
        guard scenes.indices.contains(index) else { return }
        scenes[index].selectedImage = image
        if let idx = scenes[index].generatedImages.firstIndex(of: image) {
            selectedImageIndices[index] = idx
        }
    }
    
    func updatePrompt(for index: Int, newPrompt: String) {
        guard scenes.indices.contains(index) else { return }
        scenes[index].prompt = newPrompt
    }
}
