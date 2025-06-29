//
//  SegmentedToggle.swift
//  StoryGenixApp
//
//  Created by Elif Edman on 29.06.2025.
//

import SwiftUI

struct SegmentedToggle: View {
    let options: [String]
    @Binding var selected: String

    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    selected = option
                }) {
                    Text(option)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(selected == option ? Color.purple : .white)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(selected == option ? Color.white : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
        }
        .frame(height: 48)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
