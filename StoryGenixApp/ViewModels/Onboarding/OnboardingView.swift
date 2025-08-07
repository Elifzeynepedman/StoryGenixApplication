//
//  OnboardingView.swift
//  StoryGenix
//
//  Created by Elif Edman on 3.08.2025.
//

import SwiftUI
import AVFoundation

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var selection = 0
    @State private var showPaywall = false
    @Environment(Router.self) private var router // ✅ Correct with @Observable Router

    init(hasSeenOnboarding: Binding<Bool>) {
        _hasSeenOnboarding = hasSeenOnboarding
        UIPageControl.appearance().currentPageIndicatorTintColor = .white
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.4)
    }

    var body: some View {
        ZStack {
            TabView(selection: $selection) {
                OnboardingPage(
                    title: NSLocalizedString("onboarding_intro1_title", comment: ""),
                    subtitle: NSLocalizedString("onboarding_intro1_subtitle", comment: ""),
                    videoName: "onboarding1",
                    heroText: "The city of New York was attacked when the hero decided to step up and fight back...",
                    buttonTitle: NSLocalizedString("next", comment: ""),
                    action: { selection = 1 }
                )
                .tag(0)

                OnboardingPage(
                    title: NSLocalizedString("onboarding_intro2_title", comment: ""),
                    subtitle: NSLocalizedString("onboarding_intro2_subtitle", comment: ""),
                    videoName: "onboarding2",
                    heroText: "",
                    voiceScript: "Mom! Look what I found! It’s glowing... Do you think it’s from the stars?",
                    buttonTitle: NSLocalizedString("next", comment: ""),
                    action: { selection = 2 }
                )
                .tag(1)

                LanguageSelectionView(onContinue: { selection = 3 })
                    .tag(2)

                GoalSelectionView(onContinue: { selection = 4 })
                    .tag(3)

                OnboardingPage(
                    title: NSLocalizedString("onboarding_ready_title", comment: ""),
                    subtitle: NSLocalizedString("onboarding_ready_subtitle", comment: ""),
                    videoName: "onboarding3",
                    heroText: "",
                    buttonTitle: "Start 3-Day Trial",
                    action: {
                        showPaywall = true
                    }
                )
                .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .ignoresSafeArea(.all)

            VStack {
                Spacer()
                LinearGradient(
                    colors: [Color.black.opacity(0.5), Color.clear],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: 120)
                .allowsHitTesting(false)
            }
            .ignoresSafeArea(edges: .bottom)

            if selection < 4 {
                VStack {
                    HStack {
                        Spacer()
                        Button(NSLocalizedString("skip", comment: "")) {
                            hasSeenOnboarding = true
                            router.goToHome()
                        }
                        .foregroundColor(.white.opacity(0.8))
                        .font(.system(size: 16, weight: .medium))
                        .padding(.trailing, 20)
                        .padding(.top, 10)
                    }
                    Spacer()
                }
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView(
                onContinue: {
                    showPaywall = false
                    hasSeenOnboarding = true
                    router.goToHome()
                },
                onRestore: {
                    // implement restore logic
                }
            )
        }
    }
}
