//
//  VideoScene.swift.swift
//  StoryGenixApp
//
//  Created by Elif Edman on 29.06.2025.
//

import Foundation

struct VideoScene: Identifiable {
    let id = UUID()
    var sceneText: String       // original script line
    var prompt: String          // editable Leonardo prompt
    var videoURL: URL?          // generated video (optional until generation)
    var previewImage: String    // placeholder before video
}
