//
//  ProjectStorageManager.swift
//  StoryGenix
//
//  Created by Elif Edman on 3.07.2025.
//

import Foundation

enum ProjectStorageManager {
    private static let key = "SavedProjects"

    static func save(_ projects: [VideoProject]) {
        if let data = try? JSONEncoder().encode(projects) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func load() -> [VideoProject] {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([VideoProject].self, from: data) {
            return decoded
        }
        return []
    }
}
