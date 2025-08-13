// ImageViewModel.swift
import Foundation

@MainActor
final class ImageViewModel: ObservableObject {
    @Published var scenes: [ImageScene] = []
    @Published var currentSceneIndex = 0
    @Published var isSceneLoading: [Int: Bool] = [:]

    @Published var aspectOptions = ["1:1", "9:16", "16:9"]
    @Published var selectedAspect = "1:1"

    /// For “Continue to Video” mapping
    @Published var selectedImageIndices: [Int?] = []

    func loadFromScenes(_ videoScenes: [VideoScene]) {
        // Map exactly what came from Script/Voice → keep text & prompt
        self.scenes = videoScenes.map { ImageScene(sceneText: $0.sceneText, prompt: $0.prompt) }
        self.selectedImageIndices = Array(repeating: nil, count: scenes.count)
        self.currentSceneIndex = 0
    }

    func updatePrompt(for index: Int, newPrompt: String) {
        guard scenes.indices.contains(index) else { return }
        scenes[index].prompt = newPrompt
    }

    func selectImage(_ image: String, for index: Int) {
        guard scenes.indices.contains(index) else { return }
        scenes[index].selectedImage = image
        if let idx = scenes[index].generatedImages.firstIndex(of: image) {
            selectedImageIndices[index] = idx
        }
    }

    /// Generate images for the current scene with the chosen UI aspect.
    func generateImagesForCurrentScene(projectId: String, aspectKeyword: String? = nil) {
        guard scenes.indices.contains(currentSceneIndex) else { return }

        let prompt = scenes[currentSceneIndex].prompt
        let aspect: String = aspectKeyword ?? {
            switch selectedAspect {
            case "9:16": return "portrait"
            case "16:9": return "landscape"
            default:     return "square"
            }
        }()

        isSceneLoading[currentSceneIndex] = true

        Task {
            defer { isSceneLoading[currentSceneIndex] = false }
            do {
                let images = try await ApiService.shared.generateImagesForScene(
                    projectId: projectId,
                    sceneIndex: currentSceneIndex,
                    prompt: prompt,
                    numImages: 4,
                    aspectRatio: aspect
                )

                // Normalize to 4 slots for the grid
                var normalized = images
                if normalized.count < 4, let last = normalized.last {
                    normalized.append(contentsOf: Array(repeating: last, count: 4 - normalized.count))
                }

                self.scenes[self.currentSceneIndex].generatedImages = normalized
                self.scenes[self.currentSceneIndex].selectedImage = nil

            } catch {
                print("❌ Error generating images for scene \(currentSceneIndex): \(error)")
            }
        }
    }
}
