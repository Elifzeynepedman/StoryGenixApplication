//
//  ImageScene.swift
//  StoryGenixApp
//
//  Created by Elif Edman on 29.06.2025.
//

import Foundation

struct ImageScene: Identifiable{
    let id = UUID()
    let sceneText: String
    var prompt: String // 🆕 editable Leonardo prompt
    var generatedImages: [String] = [] // still using String for image ID or name
    var selectedImage: String? = nil
}
