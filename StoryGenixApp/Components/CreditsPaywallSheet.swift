//
//  CreditsPaywallSheet.swift
//  StoryGenix
//
//  Created by Elif Edman on 11.08.2025.
//

import SwiftUI

struct CreditsPaywallSheet: View {
    @EnvironmentObject var creditsVM: CreditsViewModel
    @State private var showProPurchase = false

    private let packs: [TopUpPack] = [
        TopUpPack(id: "starter50", title: "Starter 50",
                  credits: [.image: 25, .voice: 15, .script: 5, .video: 5],
                  priceLocalized: "$4.99"),
        TopUpPack(id: "pro120",    title: "Pro 120",
                  credits: [.image: 60, .voice: 40, .script: 10, .video: 10],
                  priceLocalized: "$9.99")
    ]

    var body: some View {
        VStack(spacing: 16) {
            Capsule().fill(.secondary)
                .frame(width: 44, height: 5)
                .padding(.top, 8)

            // Header
            VStack(spacing: 6) {
                Text("You’re out of credits")
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                if let need = creditsVM.pendingAmount {
                    Text("You need \(need) more credit\(need == 1 ? "" : "s") to continue.")
                        .foregroundStyle(.white.opacity(0.8))
                }
            }

            // Current total + breakdown
            VStack(spacing: 8) {
                HStack {
                    Label("\(creditsVM.totalCredits)", systemImage: "bolt.fill")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(10)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                if let b = creditsVM.balances {
                    HStack(spacing: 10) {
                        ForEach(CreditType.allCases, id: \.rawValue) { t in
                            let v = b.credits[t] ?? 0
                            if v > 0 {
                                Label("\(v)", systemImage: icon(for: t))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.white.opacity(0.06))
                                    .clipShape(Capsule())
                                    .foregroundStyle(.white)
                                    .font(.caption)
                            }
                        }
                    }
                }
            }

            // RULE 1: Only Pro users see Top-Up Packs
            if creditsVM.isPro {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Top-Up Packs")
                        .font(.headline)
                        .foregroundStyle(.white)

                    ForEach(packs) { pack in
                        Button {
                            Task { await creditsVM.applyTopUp(pack) }
                        } label: {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(pack.title)
                                        .font(.body.weight(.semibold))
                                        .foregroundStyle(.white)
                                    Text(describe(pack.credits))
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.8))
                                }
                                Spacer()
                                Text(pack.priceLocalized)
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(.white)
                            }
                            .padding()
                            .background(Color.white.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                }
            }

            // RULE 2: Only non-Pro users see Upgrade to Pro
            if !creditsVM.isPro {
                Button {
                    showProPurchase = true
                } label: {
                    Text("Upgrade to Pro").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .padding(.top, 4)
                .fullScreenCover(isPresented: $showProPurchase) {
                    ProPurchaseView()
                        .environmentObject(creditsVM)
                }
            }

            Spacer(minLength: 8)
        }
        .padding(16)
        .background(.black)
        .presentationDetents([.fraction(0.55), .large])
        .task { await creditsVM.refresh() }
    }

    private func icon(for t: CreditType) -> String {
        switch t {
        case .script: return "text.book.closed"
        case .image:  return "photo"
        case .voice:  return "waveform"
        case .video:  return "film"
        }
    }

    private func describe(_ credits: [CreditType: Int]) -> String {
        CreditType.allCases
            .compactMap { t in
                if let v = credits[t], v > 0 { return "\(v) \(t.rawValue)" }
                return nil
            }
            .joined(separator: " • ")
    }
}

