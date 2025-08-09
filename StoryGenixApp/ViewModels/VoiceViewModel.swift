//
//  VoiceViewModel.swift
//  StoryGenix
//
//  Created by Elif Edman on 1.08.2025.
//

import Foundation
import AVFoundation

@MainActor
class VoiceViewModel: ObservableObject {

    struct Voice: Identifiable, Equatable {
        let id: String          // ElevenLabs voice ID
        let label: String       // UI name
        let previewFile: String?
    }

    @Published var selectedGender = "Female"
    @Published var selectedVoice: Voice
    @Published var isGenerating = false
    @Published var audioURL: URL? = nil           // <- changes trigger player rebuild
    @Published var errorMessage: String? = nil

    // tile indicator
    @Published var previewingVoiceId: String? = nil

    private var previewPlayer: AVAudioPlayer? = nil

    // MARK: - Your voices
    private let femaleVoices: [Voice] = [
        Voice(id: "xctasy8XvGp2cVO9HL9k", label: "Allison", previewFile: "Allison"),
        Voice(id: "ZF6FPAbjXT4488VcRRnw", label: "Amelia",  previewFile: "Amelia"),
        Voice(id: "tnSpp4vdxKPjI9w0GnoV", label: "Hope",    previewFile: "Hope"),
        Voice(id: "jqcCZkN6Knx8BJ5TBdYR", label: "Zara",    previewFile: "Zara")
    ]

    private let maleVoices: [Voice] = [
        Voice(id: "zQzvQBubVkDWYuqJYMFn", label: "Ben",   previewFile: "Ben"),
        Voice(id: "UgBBYS2sOqTuMpoF3BR0", label: "Mark",  previewFile: "Mark"),
        Voice(id: "wAGzRVkxKEs8La0lmdrE", label: "Sully", previewFile: "Sully"),
        Voice(id: "IuRRIAcbQK5AQk1XevPj", label: "Doga",  previewFile: "Doga")
    ]

    init() {
        self.selectedVoice = femaleVoices.first!
    }

    func voicesForCurrentGender() -> [Voice] {
        selectedGender == "Female" ? femaleVoices : maleVoices
    }

    func resetVoice() {
        selectedVoice = selectedGender == "Female" ? femaleVoices[0] : maleVoices[0]
        stopPreview()
    }

    // MARK: - Local Preview

    func playPreview(for voice: Voice) {
        // toggle if same tile tapped
        if previewingVoiceId == voice.id {
            stopPreview()
            return
        }

        selectedVoice = voice
        stopPreview()

        guard let name = voice.previewFile,
              let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("⚠️ Preview file not found for \(voice.label)")
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            let player = try AVAudioPlayer(contentsOf: url)
            previewPlayer = player
            player.prepareToPlay()
            player.play()
            previewingVoiceId = voice.id

            PreviewDelegate.bind(player: player) { [weak self] in
                Task { @MainActor in self?.previewingVoiceId = nil }
            }
        } catch {
            print("⚠️ Preview error: \(error.localizedDescription)")
        }
    }

    func stopPreview() {
        previewPlayer?.stop()
        previewPlayer = nil
        previewingVoiceId = nil
    }

    // MARK: - Backend Generation

    func generateVoice(projectId: String, script: String) async {
        guard !projectId.isEmpty else {
            errorMessage = "Missing Project ID"
            return
        }

        // ensure no overlapping audio anywhere
        NotificationCenter.default.post(name: .stopAllAudio, object: nil)
        stopPreview()

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

            // 🔑 cache-bust the new URL so AVPlayer doesn’t reuse the old bytes
            let base = ApiService.shared.baseURL + response.audio_url
            let unique = UUID().uuidString.lowercased()
            let urlString = base.contains("?") ? "\(base)&v=\(unique)" : "\(base)?v=\(unique)"

            if let freshURL = URL(string: urlString) {
                audioURL = freshURL          // <- triggers AudioPlayerView to rebuild item
                print("✅ New voice ready: \(freshURL)")
            } else {
                errorMessage = "Invalid audio URL from server."
            }
        } catch {
            print("⚠️ API Error: \(error.localizedDescription)")
            errorMessage = "Failed to generate voice. Please try again."
        }
    }
}

// MARK: - Keep a delegate alive until playback ends
private final class PreviewDelegate: NSObject, AVAudioPlayerDelegate {
    private var onFinish: (() -> Void)?

    static func bind(player: AVAudioPlayer, onFinish: @escaping () -> Void) {
        let proxy = PreviewDelegate()
        proxy.onFinish = onFinish
        player.delegate = proxy
        objc_setAssociatedObject(player, Unmanaged.passUnretained(player).toOpaque(),
                                 proxy, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onFinish?()
    }
}
