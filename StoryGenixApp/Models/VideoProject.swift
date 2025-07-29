//
//  VideoProject.swift
//  StoryGenix
//
//  Created by Elif Edman on 2.07.2025.
//

import Foundation

struct VideoProject: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var script: String
    var thumbnail: String
    var scenes: [VideoScene]
    var sceneDescriptions: [String] // ✅ Use this for image prompts
    var isCompleted: Bool
    var progressStep: Int
    var currentSceneIndex: Int? = nil
    var selectedImageIndices: [Int: Int] = [:]

    init(
        id: UUID = UUID(),
        title: String,
        script: String = "",
        thumbnail: String,
        scenes: [VideoScene] = [],
        sceneDescriptions: [String] = [], // ✅ Add default empty
        isCompleted: Bool,
        progressStep: Int,
        currentSceneIndex: Int? = nil
    ) {
        self.id = id
        self.title = title
        self.script = script
        self.thumbnail = thumbnail
        self.scenes = scenes
        self.sceneDescriptions = sceneDescriptions // ✅ Assign here
        self.isCompleted = isCompleted
        self.progressStep = progressStep
        self.currentSceneIndex = currentSceneIndex
    }
}
