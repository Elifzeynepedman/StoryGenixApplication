//
//  ProjectsViewModel.swift
//  StoryGenix
//
//  Created by Elif Edman on 2.07.2025.
//
//
//  ProjectsViewModel.swift
//  StoryGenix
//
//  Created by Elif Edman on 2.07.2025.
//

import Foundation

class ProjectsViewModel: ObservableObject {
    @Published var allProjects: [VideoProject] = []

    init() {
        allProjects = ProjectStorageManager.load()
    }

    func addProject(_ project: VideoProject) {
        allProjects.append(project)
        ProjectStorageManager.save(allProjects)
    }

    func updateProject(_ updated: VideoProject) {
        if let index = allProjects.firstIndex(where: { $0.id == updated.id }) {
            allProjects[index] = updated
            ProjectStorageManager.save(allProjects)
        }
    }

    func deleteProject(_ project: VideoProject) {
        allProjects.removeAll { $0.id == project.id }
        ProjectStorageManager.save(allProjects)
    }

    func shareProject(_ project: VideoProject) {
        print("Sharing: \(project.title)")
    }

    func resumeProject(_ project: VideoProject) {
        print("Resuming: \(project.title)")
    }

    func openCompletedProject(_ project: VideoProject) {
        print("Opening completed project: \(project.title)")
    }

    /// ✅ Replaces any unfinished draft (by same title or ID) with completed version
    func replaceWithCompleted(_ completed: VideoProject) {
        allProjects.removeAll {
            $0.id == completed.id || ($0.title == completed.title && !$0.isCompleted)
        }
        allProjects.append(completed)
        ProjectStorageManager.save(allProjects)
    }
}
