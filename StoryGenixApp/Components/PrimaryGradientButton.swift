//
//  PrimaryGradientButton.swift
//  StoryGenixApp
//
//  Created by Elif Edman on 29.06.2025.
//

import SwiftUI

struct PrimaryGradientButton: View {
    let title: String
    var isLoading: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                action()
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color("ButtonGradient1"),
                                Color("ButtonGradient2"),
                                Color("ButtonGradient3")
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 55)
                    .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 4)

                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.4), radius: 1, x: 0, y: 1)
                }
            }
        }
        .frame(maxWidth: 340) // ✅ Apple-like size
        .padding(.vertical, 8)
        .scaleEffect(isLoading ? 1.0 : 1.02)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isLoading)
    }
}
