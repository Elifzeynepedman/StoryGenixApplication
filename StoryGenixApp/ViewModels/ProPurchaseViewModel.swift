//
//  ProPurchaseView.swift
//  StoryGenix
//
//  Created by Elif Edman on 11.08.2025.
//

//
//  ProPurchaseView.swift
//  StoryGenix
//
//  Created by Elif Edman on 11.08.2025.
//
//
//  ProPurchaseView.swift
//  StoryGenix
//
//  Created by Elif Edman on 11.08.2025.
//

import SwiftUI
import StoreKit

// MARK: - ViewModel

@MainActor
final class ProPurchaseViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isPurchasing = false
    @Published var errorMessage: String?

    // Your product IDs
    private let yearlyId = "com.myaidirector.pro.yearly"
    private let weeklyId = "com.myaidirector.pro.weekly"

    var yearly: Product? { products.first(where: { $0.id == yearlyId }) }
    var weekly: Product? { products.first(where: { $0.id == weeklyId }) }

    func loadProducts() async {
        do {
            products = try await Product.products(for: [yearlyId, weeklyId])
                .sorted { $0.id < $1.id }
        } catch {
            errorMessage = "Couldn’t load products."
        }
    }

    func buy(_ product: Product) async {
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            let result = try await product.purchase()
            if case .success(let v) = result, case .unverified = v {
                errorMessage = "Purchase couldn’t be verified."
            }
        } catch {
            errorMessage = (error as NSError).localizedDescription
        }
    }

    func restore() async {
        do { try await AppStore.sync() }
        catch { errorMessage = "Restore failed." }
    }
}

// MARK: - View
// MARK: - View
struct ProPurchaseView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var creditsVM: CreditsViewModel
    @StateObject private var vm = ProPurchaseViewModel()

    var body: some View {
        ZStack {
            // Background
            Image("pro_paywall_bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            LinearGradient(
                colors: [.black.opacity(0.25), .clear, .black.opacity(0.85)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .padding(10)
                            .background(.black.opacity(0.3))
                            .clipShape(Circle())
                            .foregroundStyle(.white)
                    }
                    .padding(.leading, 20)
                    Spacer()
                }
                .padding(.top, 12)

                Spacer()

                // Main content pinned to bottom
                VStack(spacing: 18) {
                    Text("My AI Director PRO")
                        .font(.system(size: 36, weight: .heavy))
                        .foregroundColor(.white)
                        .shadow(radius: 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 26)

                    VStack(alignment: .leading, spacing: 12) {
                        bullet("Cinematic AI videos with sound")
                        bullet("6+ AI engines in 1 app")
                        bullet("200+ effects library")
                        bullet("100% ad-free")
                        bullet("200 coins per week!")
                    }
                    .padding(.horizontal, 26)

                    if let yearly = vm.yearly {
                        Text("All this for just \(yearly.displayPrice)/week")
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.horizontal, 26)
                            .padding(.top, 4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // ✅ Plan cards
                    VStack(spacing: 12) {
                        if let y = vm.yearly {
                            PlanCard(
                                title: "YEARLY ACCESS",
                                subtitle: "just \(y.displayPrice) per year",
                                priceRight: weekifiedPrice(for: y),
                                rightCaption: "per week",
                                isBestOffer: true
                            ) { Task { await vm.buy(y) } }
                        }
                        if let w = vm.weekly {
                            PlanCard(
                                title: "WEEKLY ACCESS",
                                subtitle: "200 coins per week!",
                                priceRight: w.displayPrice,
                                rightCaption: "per week"
                            ) { Task { await vm.buy(w) } }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, 140)
            }
        }
        // Footer
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 10) {
                Button {
                    if let y = vm.yearly {
                        Task { await vm.buy(y) }
                    } else if let w = vm.weekly {
                        Task { await vm.buy(w) }
                    }
                } label: {
                    Text(vm.isPurchasing ? "Purchasing…" : "Continue")
                        .font(.title3.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                }
                .disabled(vm.isPurchasing || (vm.yearly == nil && vm.weekly == nil))
                .background(
                    LinearGradient(
                        colors: [
                            Color(#colorLiteral(red: 0.78, green: 0.52, blue: 1.0, alpha: 1.0)),
                            Color(#colorLiteral(red: 1.0, green: 0.65, blue: 0.76, alpha: 1.0))
                        ],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

                HStack(spacing: 28) {
                    Button("Terms") { openURL("https://your.domain/terms") }
                    Button("Privacy Policy") { openURL("https://your.domain/privacy") }
                    Button("Restore") { Task { await vm.restore() } }
                }
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.85))
                .padding(.bottom, 10)
            }
            .background(
                Rectangle()
                    .fill(Color.black.opacity(0.35))
                    .ignoresSafeArea()
            )
        }
        .task { await vm.loadProducts() }
        .alert("Purchase", isPresented: .constant(vm.errorMessage != nil)) {
            Button("OK", role: .cancel) { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }

    // Helpers
    private func bullet(_ text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.white)
            Text(text)
                .foregroundColor(.white)
                .font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func openURL(_ url: String) {
        guard let u = URL(string: url) else { return }
        UIApplication.shared.open(u)
    }

    private func weekifiedPrice(for product: Product) -> String {
        if let price = Double(product.displayPrice.filter("0123456789.".contains)) {
            let perWeek = price / 52.0
            let nf = NumberFormatter()
            nf.numberStyle = .currency
            nf.locale = .current
            return nf.string(from: NSNumber(value: perWeek)) ?? "\(perWeek)"
        }
        return product.displayPrice
    }
}

private struct PlanCard: View {
    let title: String
    let subtitle: String
    let priceRight: String
    let rightCaption: String
    var isBestOffer: Bool = false
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                // Card
                HStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(title)
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.white)

                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.85))
                    }

                    Spacer(minLength: 10)

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(priceRight)
                            .font(.title3.weight(.bold))
                            .foregroundColor(.white)
                        Text(rightCaption)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.75))
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.white.opacity(0.10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(.white.opacity(0.25), lineWidth: 1)
                        )
                )

                // Badge
                if isBestOffer {
                    Text("BEST OFFER")
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.purple.opacity(0.9))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .offset(x: -8, y: -10)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    ProPurchaseView()
        .environmentObject(CreditsViewModel())
}
