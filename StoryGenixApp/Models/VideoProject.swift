//
//  VideoProject.swift
//  StoryGenix
//
//  Created by Elif Edman on 2.07.2025.
//

import Foundation

struct VideoProject: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var thumbnail: String // image asset name or local path
    var isCompleted: Bool
    var progressStep: Int // 0 to 4

    init(id: UUID = UUID(), title: String, thumbnail: String, isCompleted: Bool, progressStep: Int) {
        self.id = id
        self.title = title
        self.thumbnail = thumbnail
        self.isCompleted = isCompleted
        self.progressStep = progressStep
    }
}
