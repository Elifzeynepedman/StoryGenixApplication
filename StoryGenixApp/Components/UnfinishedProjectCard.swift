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
        HStack(spacing: 14) {
            // Thumbnail
            Image(project.thumbnail)
                .resizable()
                .scaledToFill()
                .frame(width: 90, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 4)

            VStack(alignment: .leading, spacing: 8) {
                Text(project.title)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .lineLimit(1)

                ProgressView(value: Double(project.progressStep), total: 4)
                    .accentColor(Color("ButtonGradient2"))

                Text(statusLabel(for: project.progressStep))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()

            Button(action: {
                if let latest = viewModel.project(for: project.id) {
                    viewModel.resumeProject(latest, using: router)
                }
            }) {
                Image(systemName: "play.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .bold))
                    .padding(14)
                    .shadow(color: Color("ButtonGradient2").opacity(0.5), radius: 6)
            }

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.white)
                    .padding(8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 1))
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
