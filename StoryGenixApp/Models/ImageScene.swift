//
//  ImageScene.swift
//  StoryGenixApp
//
//  Created by Elif Edman on 29.06.2025.
//

import Foundation

struct ImageScene: Identifiable {
    let id = UUID()
    let sceneText: String
    var generatedImages: [String] = []
    var selectedImage: String? = nil
}
