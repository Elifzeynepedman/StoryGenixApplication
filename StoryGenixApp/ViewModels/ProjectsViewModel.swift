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
        if !allProjects.contains(where: { $0.id == project.id }) {
            allProjects.append(project)
            ProjectStorageManager.save(allProjects)
        }
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

    func openCompletedProject(_ project: VideoProject) {
        print("Opening completed project: \(project.title)")
    }

    func replaceWithCompleted(_ completed: VideoProject) {
        allProjects.removeAll {
            $0.id == completed.id || ($0.title == completed.title && !$0.isCompleted)
        }
        allProjects.append(completed)
        ProjectStorageManager.save(allProjects)
    }

    func project(for id: UUID) -> VideoProject? {
        allProjects.first(where: { $0.id == id })
    }

    func resumeProject(_ project: VideoProject, using router: Router) {
        print("Resuming: \(project.title) at step \(project.progressStep)")
        router.goToStep(for: project)
    }
    
    func upsertAndNavigate(_ project: VideoProject, route: (VideoProject) -> Void) {
        if self.project(for: project.id) != nil {
            updateProject(project)
        } else {
            addProject(project)
        }
        route(project)
    }
    func resetProjects() {
        allProjects.removeAll()
    }
}
