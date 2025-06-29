//
//  VideoPreviewViewModel.swift
//  StoryGenix
//
//  Created by Elif Edman on 29.06.2025.
//

import Foundation

class VideoPreviewViewModel: ObservableObject {
    @Published var scenes: [VideoScene] = []
    @Published var currentSceneIndex: Int = 0

    var currentScene: VideoScene? {
        guard scenes.indices.contains(currentSceneIndex) else { return nil }
        return scenes[currentSceneIndex]
    }

    // Computed property for UI clarity
    var isOnLastScene: Bool {
        currentSceneIndex == scenes.count - 1
    }

    init() {
        let url = Bundle.main.url(forResource: "EfesVideo", withExtension: "mp4")
        for idx in 0..<6 {
            scenes.append(VideoScene(index: idx, videoURL: url, previewImage: "CyberCat"))
        }
    }

    func nextScene() {
        if currentSceneIndex < scenes.count - 1 {
            currentSceneIndex += 1
        }
    }

    func prevScene() {
        if currentSceneIndex > 0 {
            currentSceneIndex -= 1
        }
    }
}

