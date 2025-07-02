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

                Text("Step \(project.progressStep) of 4")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()

            Button(action: {
                print("Resume tapped")
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
}
