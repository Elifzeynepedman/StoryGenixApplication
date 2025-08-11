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
    var prompt: String
    var generatedImages: [String] = []       // absolute/relative URLs returned by backend
    var selectedImage: String? = nil
}
