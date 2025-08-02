//
//  SafeSubscript.swift
//  StoryGenix
//
//  Created by Elif Edman on 2.08.2025.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
