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

    @State private var isViewPressed = false
    @State private var isDeletePressed = false
    @State private var showPreview = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(project.thumbnail)
                .resizable()
                .aspectRatio(1, contentMode: .fill)
                .frame(height: 150)
                .cornerRadius(14)

            Text(project.title)
                .font(.subheadline)
                .foregroundColor(.white)
                .lineLimit(1)

            HStack {
                Button(action: {
                    isViewPressed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        isViewPressed = false
                        showPreview = true
                    }
                }) {
                    Text("View")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isViewPressed ? Color.white.opacity(0.2) : Color.clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white, lineWidth: 1)
                        )
                        .animation(.easeInOut(duration: 0.2), value: isViewPressed)
                }

                Spacer()

                Button(action: {
                    isDeletePressed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        isDeletePressed = false
                        onDelete()
                    }
                }) {
                    Text("Delete")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isDeletePressed ? Color.white.opacity(0.2) : Color.clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white, lineWidth: 1)
                        )
                        .animation(.easeInOut(duration: 0.2), value: isDeletePressed)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(14)
        .sheet(isPresented: $showPreview) {
            ProjectPreviewModal(project: project, isPresented: $showPreview)
        }
    }
}

