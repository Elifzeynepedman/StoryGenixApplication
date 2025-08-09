//
//  MainAppHomeView.swift
//  StoryGenix
//
//  Created by Elif Edman on 7.07.2025.
//

import SwiftUI
import Speech
import AVFoundation

struct MainAppHomeView: View {
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @Environment(Router.self) private var router

    @State private var topic: String = ""
    @State private var showEmptyError = false
    @State private var micPulse = false

    let randomTopics = [
        "The Eye of a Storm",
        "How Dreams Are Made",
        "A Robot Learns to Paint",
        "The Lost Temple of Sound",
        "What If Trees Could Talk?"
    ]

    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()

            VStack(spacing: 4) {
                // Title
                HStack {
                    Text("My AI Director")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(.white)
                    Image(systemName: "star.fill")
                        .foregroundStyle(Color.pink)
                }

                // Subtitle
                HStack(spacing: 30) {
                    Text("One Topic")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                    Text("Script, Voice, Images, Video")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                }
                .padding(.bottom, 60)

                // Input Card
                VStack(spacing: 14) {
                    Text("What video would you like to create?")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 3)

                    Spacer()

                    // Input + Mic Button
                    HStack(alignment: .top, spacing: 8) {
                        ZStack(alignment: .topLeading) {
                            if topic.isEmpty {
                                Text("Describe your topic here...")
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(14)
                            }

                            TextEditor(text: $topic)
                                .foregroundColor(.white)
                                .padding(10)
                                .frame(height: 100)
                                .background(Color.clear)
                                .scrollContentBackground(.hidden)
                        }

                        Button(action: {
                            if speechRecognizer.isRecording {
                                speechRecognizer.stopTranscribing()
                            } else {
                                speechRecognizer.transcript = topic // sync current input
                                speechRecognizer.requestAuthorization { granted in
                                    if granted {
                                        try? speechRecognizer.startTranscribing()
                                    }
                                }
                            }
                        }) {
                            ZStack {
                                if speechRecognizer.isRecording {
                                    Circle()
                                        .fill(Color("DarkTextColor").opacity(0.4))
                                        .frame(width: 34, height: 34)
                                        .scaleEffect(micPulse ? 1.2 : 0.8)
                                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: micPulse)
                                }

                                Image(systemName: "mic.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white.opacity(0.85))
                            }
                            .padding(.top, 12)
                            .padding(.trailing, 6)
                        }
                    }
                    .frame(height: 100)
                    .padding(.horizontal, 10)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color("BackgroundGradientDark"),
                                Color("BackgroundGradientPurple"),
                                Color("BackgroundGradientNavy")
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .opacity(0.4)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white, lineWidth: 0.5)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal, 30)
                    .padding(.top, -20)

                    // Surprise Me Button
                    Button(action: {
                        topic = randomTopics.randomElement() ?? "The Universe"
                        showEmptyError = false
                        speechRecognizer.transcript = topic
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                            Text("Surprise Me")
                        }
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.85))
                    }

                    // Generate Video Button
                    Button(action: {
                        let trimmed = topic.trimmingCharacters(in: .whitespacesAndNewlines)
                        if trimmed.isEmpty {
                            showEmptyError = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showEmptyError = false
                            }
                        } else {
                            Task {
                                do {
                                    let project = try await ApiService.shared.createProject(title: trimmed, topic: trimmed)
                                    router.goToScript(project: project)
                                } catch {
                                    print("❌ Failed to create project:", error.localizedDescription)
                                }
                            }
                        }
                    }) {
                        Text("Generate Video")
                            .font(.headline)
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color("ButtonGradient1"),
                                        Color("ButtonGradient2"),
                                        Color("ButtonGradient3")
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(.rect(cornerRadius: 18))
                            .shadow(color: .black.opacity(0.07), radius: 4, x: 0, y: 2)
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 30)


                    // Error Message
                    if showEmptyError {
                        Text("Please enter a topic or generate one.")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.top, 4)
                    }

                    Spacer()
                }
                .frame(width: 350, height: 320)
                .padding(.top, 40)
                .background(Color.white.opacity(0.08))
                .cornerRadius(28)
                .padding(.horizontal)
            }
        }
        .frame(maxHeight: .infinity, alignment: .center)
        .onReceive(speechRecognizer.$transcript) { live in
            topic = live // always append to whatever was there
        }
        .onChange(of: speechRecognizer.isRecording) {
            micPulse = speechRecognizer.isRecording
        }
    }
}
