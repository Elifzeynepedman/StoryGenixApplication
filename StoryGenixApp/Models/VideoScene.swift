//
//  VideoScene.swift.swift
//  StoryGenixApp
//
//  Created by Elif Edman on 29.06.2025.
//

import Foundation

struct VideoScene: Identifiable {
    let id = UUID()
    let index: Int
    let videoURL: URL?
    let previewImage: String 
}
