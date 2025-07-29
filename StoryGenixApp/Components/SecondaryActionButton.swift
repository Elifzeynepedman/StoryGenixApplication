//
//  SecondaryActionButton.swift
//  StoryGenixApp
//
//  Created by Elif Edman on 29.06.2025.
//

import SwiftUI

struct SecondaryActionButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(height: 44)
                .frame(maxWidth: .infinity)
                .background(Color("DarkTextColor"))
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal ,40)

    }
}
