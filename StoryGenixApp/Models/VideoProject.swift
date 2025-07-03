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
    var isCompleted: Bool
    var progressStep: Int

    init(
        id: UUID = UUID(),
        title: String,
        script: String = "",
        thumbnail: String,
        scenes: [VideoScene] = [],
        isCompleted: Bool,
        progressStep: Int
    ) {
        self.id = id
        self.title = title
        self.script = script
        self.thumbnail = thumbnail
        self.scenes = scenes
        self.isCompleted = isCompleted
        self.progressStep = progressStep
    }
}
