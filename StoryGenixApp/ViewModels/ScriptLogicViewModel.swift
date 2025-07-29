//
//  ScriptLogicViewModel.swift
//  StoryGenix
//
//  Created by Elif Edman on 29.07.2025.
//

import Foundation

@MainActor
class ScriptLogicViewModel: ObservableObject {
    @Published var script: String = ""
    @Published var scenes: [String] = []  // Only descriptions for images
    @Published var isLoading = false

    var displayScript: String {
        var text = script

        // Remove headings like ### Script or **Script:** or "Script:"
        text = text.replacingOccurrences(of: "### Script", with: "", options: .caseInsensitive)
        text = text.replacingOccurrences(of: "##", with: "", options: .caseInsensitive)
        text = text.replacingOccurrences(of: "**Script:**", with: "", options: .caseInsensitive)
        text = text.replacingOccurrences(of: "Script:", with: "", options: .caseInsensitive)

        // Remove everything after "Scenes:" or "**Scenes:**" or "### Scenes"
        if let range = text.range(of: "Scenes:", options: .caseInsensitive) {
            text = String(text[..<range.lowerBound])
        }

        if let range = text.range(of: "**Scenes:**", options: .caseInsensitive) {
            text = String(text[..<range.lowerBound])
        }

        if let range = text.range(of: "### Scenes", options: .caseInsensitive) {
            text = String(text[..<range.lowerBound])
        }

        // Remove Kling section if it exists
        if let klingRange = text.range(of: "🎥", options: .caseInsensitive) {
            text = String(text[..<klingRange.lowerBound])
        }

        // Remove numbered lists like "1." or "1)"
        text = text.replacingOccurrences(of: #"(?m)^\d+[\.\)]\s*"#, with: "", options: .regularExpression)

        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func generateScript(for topic: String) async {
        isLoading = true
        do {
            let response = try await ApiService.shared.generateScript(topic: topic, projectId: "mock123")
            self.script = response.script
            self.scenes = response.scenes.map { $0.text }  // ✅ Extract only scene text
        } catch {
            print("❌ Error generating script: \(error)")
            self.script = "Error generating script."
            self.scenes = []
        }
        isLoading = false
    }
}
