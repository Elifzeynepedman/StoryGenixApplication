//
//  FullscreenVideoView.swift
//  StoryGenix
//
//  Created by Elif Edman on 4.08.2025.
//

import SwiftUI
import AVKit

struct FullscreenVideoView: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black

        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = UIScreen.main.bounds
        view.layer.addSublayer(playerLayer)

        DispatchQueue.main.async {
            player.play()
            player.isMuted = true
            player.actionAtItemEnd = .none

            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem,
                queue: .main
            ) { _ in
                player.seek(to: .zero)
                player.play()
            }
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let layer = uiView.layer.sublayers?.first as? AVPlayerLayer {
            layer.frame = UIScreen.main.bounds
        }
    }
}
