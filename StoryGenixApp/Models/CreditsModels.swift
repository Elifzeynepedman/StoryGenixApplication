//
//  CreditsModels.swift
//  StoryGenix
//
//  Created by Elif Edman on 11.08.2025.
//

import Foundation

enum CreditType: String, Codable, CaseIterable {
    case script, image, voice, video
}

struct CreditBalances: Codable {
    let planId: String
    var credits: [CreditType: Int]
    var extraPurchases: [TopUpPurchase]?

    init(planId: String, credits: [CreditType: Int], extraPurchases: [TopUpPurchase]? = nil) {
        self.planId = planId
        self.credits = credits
        self.extraPurchases = extraPurchases
    }

    subscript(_ type: CreditType) -> Int {
        credits[type] ?? 0
    }
}

struct PlanInfo: Codable, Identifiable {
    let id: String
    let name: String
    let monthlyCredits: [CreditType: Int]
    let priceLocalized: String?    // optional, fill from backend or StoreKit
}

struct TopUpPack: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let credits: [CreditType: Int]
    let priceLocalized: String
}

struct TopUpPurchase: Codable, Identifiable {
    let id: String
    let packId: String
    let createdAt: Date
}
