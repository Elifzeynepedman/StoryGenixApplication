// CreditsViewModel.swift
import Foundation
import SwiftUI

@MainActor
final class CreditsViewModel: ObservableObject {
    @Published var balances: CreditBalances? = nil
    @Published var plans: [PlanInfo] = []
    @Published var isLoading = false
    @Published var showPaywall = false
    @Published var pendingAmount: Int? = nil
    @Published var lastError: String? = nil   // optional: surface failures

    private let service = CreditsService.shared

    // MARK: - Derived
    var isPro: Bool {
        (balances?.planId.lowercased() ?? "free") == "pro"
    }

    // Total pooled credits = sum of all types we currently track
    var totalCredits: Int {
        guard let map = balances?.credits else { return 0 }
        return map.values.reduce(0, +)
    }

    // MARK: - Load
    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            async let b = service.fetchUserCredits()
            async let p = service.fetchPlans()
            let (balances, plans) = try await (b, p)
            self.balances = balances
            self.plans = plans
            self.lastError = nil
        } catch {
            self.lastError = error.localizedDescription
        }
    }

    // MARK: - Unified total pool
    func requireTotal(_ amount: Int) -> Bool {
        guard amount > 0 else { return true }
        if totalCredits >= amount { return true }
        pendingAmount = amount
        showPaywall = true
        return false
    }

    func deductTotal(_ amount: Int, preferred: CreditType? = nil) {
        guard amount > 0, var b = balances else { return }
        var remaining = amount

        if let pref = preferred, let have = b.credits[pref], have > 0 {
            let use = min(have, remaining)
            b.credits[pref] = have - use
            remaining -= use
        }

        if remaining > 0 {
            for t in CreditType.allCases where t != preferred {
                let have = b.credits[t] ?? 0
                guard have > 0 else { continue }
                let use = min(have, remaining)
                b.credits[t] = have - use
                remaining -= use
                if remaining == 0 { break }
            }
        }

        balances = b
    }

    // MARK: - Top-up (Pro only)
    func applyTopUp(_ pack: TopUpPack) async {
        guard isPro else {
            // hard stop: non‑Pro users cannot buy top‑ups
            lastError = "Top-ups are available for Pro plans only."
            return
        }
        do {
            try await service.purchaseTopUp(pack)
            await refresh()
            showPaywall = false
            pendingAmount = nil
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }
}
