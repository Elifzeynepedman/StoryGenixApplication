//
//  VoiceViewModel.swift
//  StoryGenix
//
//  Created by Elif Edman on 1.08.2025.
//

import Foundation

@MainActor
class VoiceViewModel: ObservableObject {
    struct Voice: Identifiable, Equatable {
        let id: String         // This is the ElevenLabs voice ID
        let label: String      // Human-readable name (e.g. "Rachel")
    }

    @Published var selectedGender = "Female"
    @Published var selectedVoice: Voice
    @Published var isGenerating = false
    @Published var audioURL: URL? = nil
    @Published var errorMessage: String? = nil

    private let femaleVoices: [Voice] = [
        Voice(id: "21m00Tcm4TlvDq8ikWAM", label: "Rachel"),
        Voice(id: "AZnzlk1XvdvUeBnXmlld", label: "Domi"),
        Voice(id: "EXAVITQu4vr4xnSDxMaL", label: "Bella"),
        Voice(id: "pNInz6obpgDQGcFmaJgB", label: "Sarah")
    ]

    private let maleVoices: [Voice] = [
        Voice(id: "TxGEqnHWrfWFTfGW9XjX", label: "Josh"),
        Voice(id: "VR6AewLTigWG4xSOukaG", label: "Arnold"),
        Voice(id: "ErXwobaYiN019PkySvjV", label: "Antoni"),
        Voice(id: "MF3mGyEYCl7XYWbV9V6O", label: "Elli")
    ]

    init() {
        // Default selected voice
        self.selectedVoice = femaleVoices.first!
    }

    func voicesForCurrentGender() -> [Voice] {
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
            let response = try await ApiService.shared.generateVoice(
                projectId: projectId,
                voiceId: selectedVoice.id,
                script: script,
                sceneIndex: 0
            )

            if let url = URL(string: ApiService.shared.baseURL + response.audio_url) {
                audioURL = url
                print("✅ Voice generated: \(url)")
            } else {
                errorMessage = "Invalid audio URL from server."
            }

        } catch {
            print("⚠️ API Error: \(error.localizedDescription)")
            errorMessage = "Failed to generate voice. Please try again."
        }

        // Optional fallback
        if audioURL == nil, let path = Bundle.main.path(forResource: "sample", ofType: "mp3") {
            audioURL = URL(fileURLWithPath: path)
            print("✅ Using bundled mock audio as fallback.")
        }
    }
}
