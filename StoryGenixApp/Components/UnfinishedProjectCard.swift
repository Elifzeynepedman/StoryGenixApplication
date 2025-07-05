//
//  UnfinishedProjectCard.swift
//  StoryGenix
//
//  Created by Elif Edman on 2.07.2025.
//

import SwiftUI

struct UnfinishedProjectCard: View {
    let project: VideoProject
    var onDelete: () -> Void

    @EnvironmentObject private var viewModel: ProjectsViewModel
    @Environment(Router.self) private var router

    var body: some View {
        HStack {
            Image(project.thumbnail)
                .resizable()
                .aspectRatio(1, contentMode: .fill)
                .frame(width: 90, height: 90)
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 6) {
                Text(project.title)
                    .font(.headline)
                    .foregroundColor(.white)

                ProgressView(value: Double(project.progressStep), total: 4)
                    .accentColor(.white)

                Text(statusLabel(for: project.progressStep))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()

            Button(action: {
                if let latest = viewModel.project(for: project.id) {
                    viewModel.resumeProject(latest, using: router)
                } else {
                    print("⚠️ Could not find latest version of project \(project.id)")
                }
            }) {
                Image(systemName: "play.fill")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.blue)
                    .clipShape(Circle())
            }

            Button(action: {
                onDelete()
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .padding(8)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(14)
    }

    private func statusLabel(for step: Int) -> String {
        switch step {
        case 1: return "Continue from Voice"
        case 2: return "Continue from Images"
        case 3: return "Continue from Video"
        default: return "Continue Project"
        }
    }
}
