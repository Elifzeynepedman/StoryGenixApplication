//
//  CompletedProjectCard.swift
//  StoryGenix
//
//  Created by Elif Edman on 2.07.2025.
//

import SwiftUI

struct CompletedProjectCard: View {
    let project: VideoProject
    let onDelete: () -> Void

    @State private var showPreview = false

    var body: some View {
        VStack(spacing: 10) {
            // Thumbnail
            Image(project.thumbnail)
                .resizable()
                .scaledToFill()
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 4)

            // Title
            Text(project.title)
                .font(.subheadline.bold())
                .foregroundColor(.white)
                .lineLimit(1)

            // Actions
            HStack(spacing: 12) {
                Button(action: { showPreview = true }) {
                    Text("View")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 35)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1)
                        )
                }

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.white)
                        .padding(8)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 1))
        .sheet(isPresented: $showPreview) {
            ProjectPreviewModal(project: project, isPresented: $showPreview)
        }
    }
}


