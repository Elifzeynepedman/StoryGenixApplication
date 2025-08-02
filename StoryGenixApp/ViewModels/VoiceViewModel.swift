//
//  VoiceViewModel.swift
//  StoryGenix
//
//  Created by Elif Edman on 1.08.2025.
//

import Foundation

@MainActor
class VoiceViewModel: ObservableObject {
    @Published var selectedGender = "Female"
    @Published var selectedVoice = "Jennie"
    @Published var isGenerating = false
    @Published var audioURL: URL? = nil
    @Published var errorMessage: String? = nil

    private let femaleVoices = ["Jennie", "Elif", "Sarah", "Katie"]
    private let maleVoices = ["Brian", "David", "Alex", "Mike"]

    func voicesForCurrentGender() -> [String] {
        selectedGender == "Female" ? femaleVoices : maleVoices
    }

    func resetVoice() {
        selectedVoice = selectedGender == "Female" ? femaleVoices[0] : maleVoices[0]
    }

    func generateVoice(projectId: String, script: String) async {
        guard !projectId.isEmpty else {
            errorMessage = "Missing Project ID"
            return
        }
        isGenerating = true
        defer { isGenerating = false }

        do {
            let response = try await ApiService.shared.generateVoice(
                projectId: projectId,
                voiceId: selectedVoice,
                script: script,
                sceneIndex: 0
            )

            if let url = URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3") {
                audioURL = url
                print("✅ Using remote URL for playback: \(url)")
                return
            }

            


        } catch {
            print("⚠️ API failed: \(error.localizedDescription)")
        }

        // ✅ Fallback: Bundled mock audio
        if let path = Bundle.main.path(forResource: "sample", ofType: "mp3") {
            audioURL = URL(fileURLWithPath: path)
            print("✅ Using bundled mock audio.")
        } else {
            errorMessage = "Failed to load audio."
        }
    }
}

