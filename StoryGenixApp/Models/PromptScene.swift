//
//  PromptScene.swift
//  StoryGenix
//
//  Created by Elif Edman on 1.07.2025.
//

import Foundation

protocol PromptScene: Identifiable {
    var sceneText: String { get set }
     var prompt: String { get set }
}
