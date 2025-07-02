//
//  MediaSaver.swift
//  StoryGenix
//
//  Created by Elif Edman on 30.06.2025.
//


import Foundation
import Photos

struct MediaSaver {
    static func saveVideoToPhotoLibrary(from url: URL, onComplete: ((Bool) -> Void)? = nil) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                onComplete?(false)
                return
            }

            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            }) { success, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error saving video: \(error.localizedDescription)")
                    }
                    onComplete?(success)
                }
            }
        }
    }
}
