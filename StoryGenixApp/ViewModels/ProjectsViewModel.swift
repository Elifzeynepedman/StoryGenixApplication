//
//  ProjectsViewModel.swift
//  StoryGenix
//
//  Created by Elif Edman on 2.07.2025.
//

import Foundation
import SwiftUI

class ProjectsViewModel: ObservableObject {
    @Published var allProjects: [VideoProject] = []

    init() {
        loadMockProjects()
    }

    func loadMockProjects() {
        allProjects = [
            VideoProject(title: "The Apple Kid", thumbnail: "Thumbnail1", isCompleted: false, progressStep: 2),
            VideoProject(title: "The Birth of Venus", thumbnail: "Thumbnail2", isCompleted: true, progressStep: 4)
        ]
    }

    func deleteProject(_ project: VideoProject) {
        allProjects.removeAll { $0.id == project.id }
    }
}
