//
//  ScriptLogicViewModel.swift
//  StoryGenix
//
//  Created by Elif Edman on 29.07.2025.
//

import SwiftUI


@MainActor
class ScriptLogicViewModel: ObservableObject {
    @Published var script: String = ""
    @Published var scenes: [SceneResponse] = [] // full scene objects
    @Published var isLoading = false

    var displayScript: String {
        var text = script
        text = text.replacingOccurrences(of: "### Script", with: "", options: .caseInsensitive)
        text = text.replacingOccurrences(of: "##", with: "", options: .caseInsensitive)
        text = text.replacingOccurrences(of: "**Script:**", with: "", options: .caseInsensitive)
        text = text.replacingOccurrences(of: "Script:", with: "", options: .caseInsensitive)

        if let range = text.range(of: "Scenes:", options: .caseInsensitive) {
            text = String(text[..<range.lowerBound])
        }

        if let klingRange = text.range(of: "🎥", options: .caseInsensitive) {
            text = String(text[..<klingRange.lowerBound])
        }

        text = text.replacingOccurrences(of: #"(?m)^\d+[\.\)]\s*"#, with: "", options: .regularExpression)
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func generateScript(for topic: String) async {
        isLoading = true
        do {
            let response = try await ApiService.shared.generateScript(topic: topic, projectId: "mock123")
            self.script = response.script
            self.scenes = response.scenes // ✅ Store full objects
        } catch {
            print("❌ Error generating script: \(error)")
            self.script = "Error generating script."
            self.scenes = []
        }
        isLoading = false
    }
}
