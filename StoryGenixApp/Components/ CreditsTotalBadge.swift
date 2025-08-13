//
//   CreditsTotalBadge.swift
//  StoryGenix
//
//  Created by Elif Edman on 11.08.2025.
//

import SwiftUI

struct CreditsTotalBadge: View {
    @EnvironmentObject var creditsVM: CreditsViewModel

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "bolt.fill").imageScale(.small)
            Text("\(creditsVM.totalCredits)")
                .font(.caption.weight(.bold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.14))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1))
        .task { await creditsVM.refresh() }
        .accessibilityLabel("Credits remaining")
    }
}
