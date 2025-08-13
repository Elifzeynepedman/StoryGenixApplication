//
//  CreditNoteView.swift
//  StoryGenix
//
//  Created by Elif Edman on 11.08.2025.
//

import SwiftUI

struct CreditNoteView: View {
    let cost: Int
    
    var body: some View {
        Text("Uses \(cost) credit\(cost > 1 ? "s" : "")")
            .font(.footnote)
            .foregroundColor(.white.opacity(0.85))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.white.opacity(0.15))
            .clipShape(Capsule())
            .accessibilityLabel("This action uses \(cost) credits.")
    }
}
