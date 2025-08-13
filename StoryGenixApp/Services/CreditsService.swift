//
//  CreditsService.swift
//  StoryGenix
//
//  Created by Elif Edman on 11.08.2025.
//

import Foundation

actor CreditsService {
    static let shared = CreditsService()
    private init() {}

    // GET /api/user/credits
    func fetchUserCredits() async throws -> CreditBalances {
        let req = try await ApiService.shared.makeAuthorizedRequest("/api/user/credits", method: "GET")
        let (data, _) = try await URLSession.shared.data(for: req)

        let raw = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
        let planId = raw["planId"] as? String ?? "free"
        let creditsDict = (raw["credits"] as? [String: Int]) ?? [:]

        var map: [CreditType: Int] = [:]
        for (k, v) in creditsDict {
            if let t = CreditType(rawValue: k) { map[t] = v }
        }
        return CreditBalances(planId: planId, credits: map, extraPurchases: nil)
    }

    // GET /api/plans
    func fetchPlans() async throws -> [PlanInfo] {
        let req = try await ApiService.shared.makeAuthorizedRequest("/api/plans", method: "GET")
        let (data, _) = try await URLSession.shared.data(for: req)

        let arr = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []
        return arr.compactMap { o in
            guard let id = o["id"] as? String else { return nil }
            let name = (o["name"] as? String) ?? id.capitalized
            let price = o["priceLocalized"] as? String

            var monthly: [CreditType: Int] = [:]
            if let cd = o["credits"] as? [String: Int] {
                for (k, v) in cd { if let t = CreditType(rawValue: k) { monthly[t] = v } }
            }
            return PlanInfo(id: id, name: name, monthlyCredits: monthly, priceLocalized: price)
        }
    }

    // Temporary top-up via transfer endpoint
    func purchaseTopUp(_ pack: TopUpPack) async throws {
        for (t, amount) in pack.credits {
            let payload: [String: Any] = [
                "toUserId": "me",
                "type": t.rawValue,
                "amount": amount
            ]
            let body = try JSONSerialization.data(withJSONObject: payload)
            let req = try await ApiService.shared.makeAuthorizedRequest("/api/user/transfer-credit",
                                                                        method: "POST",
                                                                        body: body)
            _ = try await URLSession.shared.data(for: req)
        }
    }
}
