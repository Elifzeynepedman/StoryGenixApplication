//
//  AudioHub.swift
//  StoryGenix
//
//  Created by Elif Edman on 9.08.2025.
//

import Foundation

extension Notification.Name {
    /// Post this to stop any audio currently playing (previews or bottom player).
    static let stopAllAudio = Notification.Name("AppAudio.StopAll")
}
