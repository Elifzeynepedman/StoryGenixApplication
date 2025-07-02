//
//  CompletedProjectCard.swift
//  StoryGenix
//
//  Created by Elif Edman on 2.07.2025.
//

import SwiftUI

struct CompletedProjectCard: View {
    let project: VideoProject

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
                    print("Share \(project.title)")
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.white)
                }

                Spacer()

                Button(action: {
                    print("View \(project.title)")
                }) {
                    Image(systemName: "play.rectangle.fill")
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(14)
    }
}
