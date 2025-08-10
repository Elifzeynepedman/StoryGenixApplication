import SwiftUI
import AVFoundation

import SwiftUI
import AVFoundation

struct AudioPlayerView: View {
    let audioURL: URL

    @State private var player: AVPlayer? = nil
    @State private var isPlaying = false
    @State private var progress: Double = 0
    @State private var duration: Double = 0
    @State private var currentTime: Double = 0
    @State private var timeObserver: Any?

    var body: some View {
        VStack(spacing: 6) { // tighter
            // Progress + times
            HStack(spacing: 8) {
                Text(formatTime(currentTime))
                    .foregroundColor(.white.opacity(0.9))
                    .font(.caption2)
                    .frame(width: 38, alignment: .leading)

                Slider(value: Binding(
                    get: { progress },
                    set: { newValue in
                        progress = newValue
                        seek(to: newValue * duration)
                    }
                ))
                .tint(.white) // slim slider, default color
                .frame(maxHeight: 24)

                Text(formatTime(duration))
                    .foregroundColor(.white.opacity(0.9))
                    .font(.caption2)
                    .frame(width: 38, alignment: .trailing)
            }
            .padding(.horizontal, 6)

            // Small Play / Pause
            Button(action: togglePlay) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .frame(width: 44, height: 44) // smaller button
                    .foregroundColor(.white)
                    .shadow(radius: 1)
            }
            .padding(.top, 2)
        }
        .onAppear { setupPlayer() }
        .onChange(of: audioURL) { _ in
            // Recreate the player to avoid caching old audio
            replaceCurrentItem(with: audioURL)
        }
        .onDisappear { cleanup() }
    }

    // MARK: - Setup

    private func setupPlayer() {
        configureAudioSession()
        replaceCurrentItem(with: audioURL)
    }

    private func replaceCurrentItem(with url: URL) {
        // Always build a fresh item (prevents stale audio after regenerate)
        let playerItem = AVPlayerItem(url: url)
        if player == nil {
            player = AVPlayer(playerItem: playerItem)
        } else {
            player?.replaceCurrentItem(with: playerItem)
        }
        isPlaying = false
        attachTimeObserver()
        observeDuration()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("⚠️ Failed to configure audio session: \(error)")
        }
    }

    private func attachTimeObserver() {
        guard let player = player else { return }
        // Remove previous
        if let observer = timeObserver { player.removeTimeObserver(observer) }
        let interval = CMTime(seconds: 0.25, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            let current = CMTimeGetSeconds(time)
            currentTime = current
            if let total = player.currentItem?.duration.seconds, total.isFinite, total > 0 {
                duration = total
                progress = current / total
            }
        }
    }

    private func observeDuration() {
        player?.currentItem?.observe(\.status, options: [.new]) { item, _ in
            if item.status == .readyToPlay {
                let total = item.duration.seconds
                if total.isFinite {
                    Task { @MainActor in duration = total }
                }
            }
        }
    }

    // MARK: - Controls

    private func togglePlay() {
        guard let player = player else { return }
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }

    private func seek(to seconds: Double) {
        let time = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: time)
    }

    // MARK: - Cleanup

    private func cleanup() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        player?.pause()
        player = nil
    }

    // MARK: - Utils

    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
