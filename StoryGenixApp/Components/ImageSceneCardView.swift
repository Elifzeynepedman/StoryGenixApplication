//
//  ImageSceneCardView.swift
//  StoryGenixApp
//
//  Created by Elif Edman on 29.06.2025.
//

import SwiftUI

struct ImageSceneCardView: View {
    let scene: ImageScene
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(scene.sceneText)
                .font(.headline)
                .foregroundColor(.white)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(scene.generatedImages.isEmpty ? Array(repeating: "", count: 4) : scene.generatedImages, id: \.self) { img in
                    Button(action: {
                        onSelect(img)
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 110)

                            if scene.generatedImages.isEmpty {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(img)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 110)
                                    .clipped()
                            }
                        }
                        .overlay(
                            ZStack {
                                if scene.selectedImage == img {
                                    Circle()
                                      .fill(Color.white)
                                      .frame(width: 24, height: 24)
                                      .position(x: 140, y: 15)
                                      .overlay(
                                        Image(systemName: "checkmark")
                                          .foregroundColor(.purple)
                                          .font(.system(size: 12, weight: .bold))
                                          .position(x: 140, y: 15)
                                        )
                                         .padding(6)
                                        
                                }
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }

            }
        }
        .padding()
        .background(Color.white.opacity(0.07))
        .cornerRadius(18)
        .padding(.horizontal)
    }
}
