//
//  AudioPlayerView.swift
//  StoryGenix
//


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
        VStack(spacing: 10) {
            // progress + times
            HStack {
                Text(formatTime(currentTime)).foregroundColor(.white).font(.caption)

                Slider(value: Binding(
                    get: { progress },
                    set: { newValue in
                        progress = newValue
                        seek(to: newValue * max(duration, 0))
                    }
                ))
                .tint(.white)

                Text(formatTime(duration)).foregroundColor(.white).font(.caption)
            }
            .padding(.horizontal)

            // play/pause
            Button(action: togglePlay) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .resizable().frame(width: 48, height: 48).foregroundColor(.white)
            }
        }
        .onAppear {
            buildPlayer(with: audioURL)
            NotificationCenter.default.addObserver(forName: .stopAllAudio, object: nil, queue: .main) { _ in
                pauseAndResetPlayState()
            }
        }
        .onChange(of: audioURL) { newURL in
            // 🔁 rebuild the item when URL changes (e.g., regeneration)
            replaceItem(with: newURL)
        }
        .onDisappear {
            teardown()
        }
    }

    // MARK: - Player wiring

    private func buildPlayer(with url: URL) {
        configureAudioSession()
        let item = AVPlayerItem(url: url)
        let newPlayer = AVPlayer(playerItem: item)
        player = newPlayer
        wireObservers(to: newPlayer)
    }

    private func replaceItem(with url: URL) {
        pauseAndResetPlayState()
        let item = AVPlayerItem(url: url)
        if player == nil {
            player = AVPlayer(playerItem: item)
        } else {
            player?.replaceCurrentItem(with: item)
        }
        wireObservers(to: player)
    }

    private func wireObservers(to player: AVPlayer?) {
        guard let player = player else { return }

        // remove old observer if any
        if let obs = timeObserver {
            player.removeTimeObserver(obs)
            timeObserver = nil
        }

        let interval = CMTime(seconds: 0.25, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            let ct = CMTimeGetSeconds(time)
            let total = CMTimeGetSeconds(player.currentItem?.duration ?? .zero)
            if total.isFinite && total > 0 {
                duration = total
                currentTime = ct
                progress = max(0, min(1, ct / total))
            }
        }

        // observe when item becomes ready to get duration correctly
        player.currentItem?.observe(\.status, options: [.new]) { item, _ in
            if item.status == .readyToPlay {
                let total = CMTimeGetSeconds(item.duration)
                if total.isFinite {
                    DispatchQueue.main.async {
                        duration = total
                    }
                }
            }
        }
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("⚠️ Audio session error: \(error)")
        }
    }

    private func teardown() {
        if let obs = timeObserver {
            player?.removeTimeObserver(obs)
            timeObserver = nil
        }
        player?.pause()
        player = nil
        isPlaying = false
    }

    private func pauseAndResetPlayState() {
        player?.pause()
        isPlaying = false
    }

    private func togglePlay() {
        guard let player = player else { return }
        if isPlaying { player.pause() } else { player.play() }
        isPlaying.toggle()
    }

    private func seek(to seconds: Double) {
        let time = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: time)
    }

    private func formatTime(_ t: Double) -> String {
        let m = Int(t) / 60
        let s = Int(t) % 60
        return String(format: "%d:%02d", m, s)
    }
}
