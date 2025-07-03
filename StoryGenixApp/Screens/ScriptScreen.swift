//
//  ScriptScreen.swift
//  StoryGenixApp
//
//  Created by Elif Edman on 29.06.2025.
//
import SwiftUI

struct ScriptScreen: View {
    let topic: String
    @State private var mode = "Auto-Generated"
    @State private var aiScriptText = ""
    @State private var customScriptText = ""
    @State private var isLoading = false
    @Environment(Router.self) private var router

    private var useAIGeneration: Bool { mode == "Auto-Generated" }
    private var currentScript: String { useAIGeneration ? aiScriptText : customScriptText }

    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("StoryGenIX")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)

                Text("Choose your script")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 10)

                SegmentedToggle(options: ["Auto-Generated", "Write My Own"], selected: $mode)
                    .padding(.horizontal, 20)

                ZStack(alignment: .topLeading) {
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color("DarkText"))

                        if !useAIGeneration && customScriptText.isEmpty {
                            Text("Write your script here...")
                                .foregroundColor(.white.opacity(0.5))
                                .padding(24)
                                .font(.system(size: 16, weight: .medium))
                        }

                        TextEditor(text: useAIGeneration ? $aiScriptText : $customScriptText)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .scrollContentBackground(.hidden)
                            .disabled(useAIGeneration)
                            .padding(20)
                    }
                }
                .frame(height: 350)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 20)

                SecondaryActionButton(title: "Continue to Images") {
                    router.goToVoice(script: currentScript, topic: topic)
                }

                if useAIGeneration {
                    Button(action: generateScript) {
                        if isLoading {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Regenerate Script")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top, 4)
                }

                Spacer()
            }
        }
        .onChange(of: mode) {
            if useAIGeneration {
                generateScript()
            } else {
                customScriptText = ""
            }
        }
        .onAppear {
            if useAIGeneration {
                generateScript()
            }
        }
    }

    func generateScript() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            aiScriptText = """
            The human eye is one of the most extraordinary organs in the body.
            It captures light, interprets color, and helps us understand the world around us.
            Behind every blink is a complex system — the cornea, lens, and retina all working together like a perfect machine.
            """
            isLoading = false
        }
    }
}

#Preview {
    ScriptScreen(topic: "How eyes work").withRouter()
}

