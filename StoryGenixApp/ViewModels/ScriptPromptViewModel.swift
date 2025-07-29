//
//  ScriptPromptSection.swift
//  StoryGenix
//
//  Created by Elif Edman on 1.07.2025.
//

import SwiftUI

struct ScriptPromptSection: View {
    let sceneText: String
    let prompt: String
    let sceneIndex: Int?
    let totalScenes: Int?
    
    let onUpdatePrompt: (String) -> Void
    let onGenerate: () -> Void
    let onPrevious: (() -> Void)?
    let onNext: (() -> Void)?
    let canGoPrevious: Bool
    let canGoNext: Bool
    let isLoading: Bool
    let shouldShowNavigation: Bool
    let generateButtonTitle: String

    var body: some View {
        VStack(spacing: 16) {
            if let sceneIndex = sceneIndex, let totalScenes = totalScenes {
                Text("Scene \(sceneIndex + 1) of \(totalScenes)")
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .semibold))
            }
            
            Text("Script:")
                .font(.footnote)
                .foregroundColor(.white.opacity(0.9))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 40)
            
            Text(sceneText)
                .foregroundColor(.white.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 40)
            
            Text("Prompt:")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 40)
            
            TextEditor(text: Binding(
                get: { prompt },
                set: { onUpdatePrompt($0) }
            ))
            .scrollContentBackground(.hidden)
            .background(Color("DarkTextColor"))
            .cornerRadius(12)
            .foregroundColor(.white)
            .padding(.horizontal, 40)
            .frame(minHeight: 150)
            
            Button(action: onGenerate) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(height: 44)
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    Text(generateButtonTitle)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 44)
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(colors: [Color.purple, Color.pink],
                                           startPoint: .leading,
                                           endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding(.horizontal, 80)

        }
    }
}
