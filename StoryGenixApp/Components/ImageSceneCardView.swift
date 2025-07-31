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
        VStack(alignment: .leading, spacing: 16) {
            // ✅ Scene Text
            Text(scene.sceneText)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 4)

            // ✅ Grid of Images
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(scene.generatedImages.isEmpty ? Array(repeating: "", count: 4) : scene.generatedImages, id: \.self) { img in
                    Button(action: { onSelect(img) }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.05))
                                .frame(height: 120)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(scene.selectedImage == img ? Color.blue : Color.white.opacity(0.2), lineWidth: 1)
                                )

                            if scene.generatedImages.isEmpty {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(img)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            }

                            // ✅ Selection Indicator
                            if scene.selectedImage == img {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 28, height: 28)
                                    .shadow(color: Color.blue.opacity(0.7), radius: 6)
                                    .overlay(
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.white)
                                            .font(.system(size: 14, weight: .bold))
                                    )
                                    .padding(8)
                                    .frame(maxWidth: .infinity, alignment: .topTrailing)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            ZStack {
                Color.black.opacity(0.25)
                LinearGradient(
                    colors: [
                        Color("BackgroundGradientDark").opacity(0.15),
                        Color("BackgroundGradientPurple").opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
}
