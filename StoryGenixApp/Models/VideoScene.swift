//
//  VideoScene.swift.swift
//  StoryGenixApp
//
//  Created by Elif Edman on 29.06.2025.
//

import Foundation

struct VideoScene: Identifiable, Codable, Hashable {
    let id: UUID
    var sceneText: String
    var prompt: String
    var videoURL: URL?
    var previewImage: String

    init(
        id: UUID = UUID(),
        sceneText: String,
        prompt: String,
        videoURL: URL? = nil,
        previewImage: String
    ) {
        self.id = id
        self.sceneText = sceneText
        self.prompt = prompt
        self.videoURL = videoURL
        self.previewImage = previewImage
    }
}
