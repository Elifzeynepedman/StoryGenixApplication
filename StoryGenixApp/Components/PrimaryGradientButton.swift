//
//  PrimaryGradientButton.swift
//  StoryGenixApp
//
//  Created by Elif Edman on 29.06.2025.
//

import SwiftUI

struct PrimaryGradientButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
            } else {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(colors: [Color.purple, Color.pink],
                                       startPoint: .leading, endPoint: .trailing)
                    )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

