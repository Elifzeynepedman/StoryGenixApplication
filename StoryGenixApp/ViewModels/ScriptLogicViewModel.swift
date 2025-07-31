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
    @Published var scenes: [SceneResponse] = [] // Full scene objects
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    /// Cleans the script text for display
    var displayScript: String {
        var text = script
        text = text.replacingOccurrences(of: "### Script", with: "", options: .caseInsensitive)
        text = text.replacingOccurrences(of: "##", with: "", options: .caseInsensitive)
        text = text.replacingOccurrences(of: "**Script:**", with: "", options: .caseInsensitive)
        text = text.replacingOccurrences(of: "Script:", with: "", options: .caseInsensitive)


        if let klingRange = text.range(of: "🎥", options: .caseInsensitive) {
            text = String(text[..<klingRange.lowerBound])
        }

        text = text.replacingOccurrences(of: #"(?m)^\d+[\.\)]\s*"#, with: "", options: .regularExpression)
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func generateScript(for topic: String) async {
            isLoading = true
            errorMessage = nil
            script = ""

            do {
                let response = try await ApiService.shared.generateScript(topic: topic, projectId: UUID().uuidString)
                self.script = response.script
                self.scenes = response.scenes
            } catch {
                print("❌ Error generating script: \(error.localizedDescription)")
                self.errorMessage = "Failed to generate script. Please try again."
            }

            isLoading = false
        }
    }
