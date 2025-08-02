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
        errorMessage = nil
        defer { isGenerating = false }

        do {
            // ✅ Call backend API
            let response = try await ApiService.shared.generateVoice(
                projectId: projectId,
                voiceId: selectedVoice,
                script: script,
                sceneIndex: 0
            )

            // ✅ Use actual backend audio URL
            if let url = URL(string: response.audio_url) {
                audioURL = url
                print("✅ Voice generated: \(url)")
                return
            } else {
                errorMessage = "Invalid audio URL from server."
            }
        } catch {
            print("⚠️ API Error: \(error.localizedDescription)")
            errorMessage = "Failed to generate voice. Please try again."
        }

        // ✅ Optional: Remove fallback for production OR keep as backup
        if let path = Bundle.main.path(forResource: "sample", ofType: "mp3") {
            audioURL = URL(fileURLWithPath: path)
            print("✅ Using bundled mock audio as fallback.")
        }
    }
}
