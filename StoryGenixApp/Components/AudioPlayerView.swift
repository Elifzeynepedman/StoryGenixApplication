//
//  AudioPlayerView.swift
//  StoryGenix
//

import SwiftUI
import AVFoundation

struct AudioPlayerView: View {
    let audioURL: URL
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var progress: Double = 0
    @State private var duration: Double = 0
    @State private var timeObserver: Any?

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(formatTime(progress * duration))
                    .foregroundColor(.white)
                    .font(.caption)

                Slider(value: Binding(
                    get: { progress },
                    set: { newValue in
                        progress = newValue
                        seek(to: newValue * duration)
                    }
                ))
                .accentColor(.blue)

                Text(formatTime(duration))
                    .foregroundColor(.white)
                    .font(.caption)
            }
            .padding(.horizontal)

            Button(action: togglePlay) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .frame(width: 48, height: 48)
                    .foregroundColor(.white)
            }
        }
        .onAppear { setupPlayer() }
        .onDisappear { cleanup() }
    }

    private func setupPlayer() {
        print("🎧 Setting up AVPlayer for: \(audioURL)")
        player = AVPlayer(url: audioURL)
        guard let player = player else { return }

        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            let currentTime = CMTimeGetSeconds(time)
            if let durationTime = player.currentItem?.duration {
                let totalSeconds = CMTimeGetSeconds(durationTime)
                if totalSeconds.isFinite {
                    duration = totalSeconds
                    progress = currentTime / duration
                }
            }
        }

        player.currentItem?.observe(\.status, options: [.new]) { item, _ in
            if item.status == .readyToPlay {
                let totalSeconds = CMTimeGetSeconds(item.duration)
                if totalSeconds.isFinite {
                    duration = totalSeconds
                    print("✅ Duration loaded: \(duration)")
                }
            }
        }
    }

    private func cleanup() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
        player?.pause()
    }

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

    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
