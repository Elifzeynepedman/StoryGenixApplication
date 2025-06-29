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
    @Published var aspectOptions = ["1:1", "9:16","16:9"]
    @Published var selectedAspect = "1:1"

    var isSceneSelected: Bool {
        guard scenes.indices.contains(currentSceneIndex) else { return false }
        return scenes[currentSceneIndex].selectedImage != nil
    }
    
    func loadScenes(from script: String) {
        let lines = script.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        scenes = lines.map { ImageScene(sceneText: $0) }
        
        // Generate for ALL scenes
        for index in scenes.indices {
            generateImages(for: index)
        }
    }

    func generateImages(for index: Int) {
        guard scenes.indices.contains(index) else { return }
        
        isLoading = true
        scenes[index].generatedImages = []  // Clear old images to show placeholders

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.scenes[index].generatedImages = ["Efes1", "Efes2", "Efes3", "Efes4"]
            self.isLoading = false
        }
    }



    func selectImage(_ image: String, for index: Int) {
        if scenes.indices.contains(index) {
            scenes[index].selectedImage = image
        }
    }
}
