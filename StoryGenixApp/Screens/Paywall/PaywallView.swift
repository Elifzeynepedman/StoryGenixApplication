//
//  PaywallView.swift
//  StoryGenix
//
//  Created by Elif Edman on 4.08.2025.
//

import SwiftUI

struct PaywallView: View {
    var onContinue: () -> Void
    var onRestore: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Text("Unlock Full Power!")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("Start your 3-day free trial and create unlimited AI videos, premium voices, and more.")
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                VStack(alignment: .leading, spacing: 16) {
                    featureRow(icon: "star.fill", color: .yellow, text: "Unlimited AI video generation")
                    featureRow(icon: "waveform.circle.fill", color: .blue, text: "Access all premium voices")
                    featureRow(icon: "paintpalette.fill", color: .pink, text: "Priority rendering speed")
                }
                .padding(.top, 20)

                Spacer()

                VStack(spacing: 16) {
                    Button(action: onContinue) {
                        Text("Start 3-Day Free Trial")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color("ButtonGradient1"), Color("ButtonGradient2"), Color("ButtonGradient3")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .padding(.horizontal)

                    Button(action: onRestore) {
                        Text("Restore Purchases")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.system(size: 14))
                    }

                    Button(action: {
                        onContinue() // Continue without upgrade
                    }) {
                        Text("Continue with Free Plan")
                            .foregroundColor(.white.opacity(0.6))
                            .font(.system(size: 14))
                            .underline()
                    }
                }
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 20)
        }
    }

    private func featureRow(icon: String, color: Color, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
            Text(text)
                .foregroundColor(.white)
                .font(.system(size: 16))
        }
    }
}
