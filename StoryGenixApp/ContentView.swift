//
//  ContentView.swift
//  StoryGenixApp
//
//  Created by Elif Edman on 29.06.2025.
//

import SwiftUI
import Speech
import AVFoundation
import UIKit

struct ContentView: View {
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @Environment(Router.self) private var router

    @State private var topic: String = ""
    @State private var showEmptyError = false
    @State private var micPulse = false
    @State private var isLoadingSurprise = false
    @FocusState private var isEditorFocused: Bool

    let suggestedIdeas = [
        "The Eye of a Storm",
        "A Robot Learns to Paint",
        "The Lost Temple of Sound"
    ]

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack {
                    // ✅ Background
                    Image("BackgroundImage")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()

                    VStack(spacing: 24) {
                        // ✅ App Branding
                        VStack(spacing: 6) {
                            Text("My AI Director")
                                .font(.system(size: 44, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(radius: 4)
                            Text("Create stunning videos in seconds")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.85))
                        }
                        .padding(.top, 50)

                        // ✅ Input Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("What video would you like to create?")
                                .font(.headline)
                                .foregroundColor(.white)

                            ZStack(alignment: .topLeading) {
                                if topic.isEmpty {
                                    Text("Describe your topic here...")
                                        .foregroundColor(.white.opacity(0.6))
                                        .padding(.top, 14)
                                        .padding(.horizontal, 8)
                                }

                                TextEditor(text: $topic)
                                    .focused($isEditorFocused)
                                    .scrollContentBackground(.hidden)
                                    .frame(height: 100)
                                    .foregroundColor(.white)
                                    .padding(.leading, 8)
                                    .padding(.trailing, 40)
                                    .background(
                                        ZStack {
                                            Color.black.opacity(0.3)
                                            LinearGradient(
                                                colors: [
                                                    Color("BackgroundGradientDark").opacity(0.2),
                                                    Color("BackgroundGradientPurple").opacity(0.15)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        }
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 18))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                    )
                                    .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
                                    .overlay(
                                        HStack {
                                            Spacer()
                                            Button(action: toggleMic) {
                                                Image(systemName: speechRecognizer.isRecording ? "stop.circle.fill" : "mic.fill")
                                                    .foregroundColor(speechRecognizer.isRecording ? .white : .gray)
                                                    .padding()
                                            }
                                        }
                                    )
                                    .toolbar {
                                        ToolbarItemGroup(placement: .keyboard) {
                                            Spacer()
                                            Button("Done") {
                                                isEditorFocused = false
                                            }
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 24)

                        // ✅ Surprise Me Button
                        Button(action: { Task { await fetchSurpriseTopic() } }) {
                            if isLoadingSurprise {
                                ProgressView().tint(.white)
                            } else {
                                HStack(spacing: 6) {
                                    Image(systemName: "sparkles")
                                    Text("Surprise Me")
                                }
                                .foregroundColor(.white.opacity(0.9))
                                .font(.subheadline)
                            }
                        }
                        .padding(.top, 8)

                        // ✅ Generate Video Button
                        Button(action: generateVideo) {
                            Text("Generate Video")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color("ButtonGradient1"),
                                            Color("ButtonGradient2"),
                                            Color("ButtonGradient3")
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 4)
                        }
                        .padding(.horizontal)

                        if showEmptyError {
                            Text("Please enter a topic or pick one.")
                                .font(.footnote)
                                .foregroundColor(.red)
                        }

                        // ✅ Suggestions
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Need inspiration?")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))

                            HStack(spacing: 12) {
                                ForEach(suggestedIdeas.prefix(2), id: \.self) { idea in
                                    suggestionButton(title: idea)
                                }
                            }
                            HStack {
                                suggestionButton(title: suggestedIdeas[2])
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 12)

                        Spacer()
                    }
                    .padding(.bottom, 40)
                    .frame(width: geo.size.width) // ✅ Lock width to prevent horizontal shift
                }
                .ignoresSafeArea(.keyboard) // ✅ Prevent screen from moving up
                .contentShape(Rectangle())
                .onTapGesture { isEditorFocused = false } // ✅ Tap anywhere closes keyboard
            }
            .navigationBarHidden(true)
            .onReceive(speechRecognizer.$transcript) { topic = $0 }
            .onAppear {
                // ✅ Firebase Anonymous Login + Backend Sync
                AuthManager.shared.signInAnonymously { result in
                    switch result {
                    case .success(let user):
                        print("✅ Anonymous sign-in success: \(user.uid)")
                        APIManager.shared.syncUser(
                            firebaseUid: user.uid,
                            email: user.email,
                            username: "anonymous"
                        )
                    case .failure(let error):
                        print("❌ Auth error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    // ✅ Suggestion Button
    private func suggestionButton(title: String) -> some View {
        Text(title)
            .font(.footnote)
            .foregroundColor(.white.opacity(0.95))
            .padding(.vertical, 8)
            .padding(.horizontal, 14)
            .background(Color.black.opacity(0.25))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color("ButtonGradient1"),
                                Color("ButtonGradient2"),
                                Color("ButtonGradient3")
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .onTapGesture { topic = ideaFor(title: title) }
    }

    private func ideaFor(title: String) -> String {
        switch title {
        case "The Eye of a Storm":
            return """
            A lone sailor battles fierce winds as the storm's eye approaches.
            Waves crash against his small boat while lightning illuminates the dark sky.
            Will he survive the wrath of nature?
            """
        case "A Robot Learns to Paint":
            return """
            In a futuristic studio, a robot picks up a paintbrush for the first time.
            Confused yet determined, it creates strokes that express a hidden spark of creativity.
            """
        case "The Lost Temple of Sound":
            return """
            Deep in the jungle, an explorer discovers a temple that hums with ancient melodies.
            Each note unlocks secrets of a forgotten civilization.
            """
        default:
            return title
        }
    }

    private func toggleMic() {
        if speechRecognizer.isRecording {
            speechRecognizer.stopTranscribing()
        } else {
            speechRecognizer.transcript = topic
            speechRecognizer.requestAuthorization { granted in
                if granted { try? speechRecognizer.startTranscribing() }
            }
        }
    }

    private func generateVideo() {
        let trimmed = topic.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            showEmptyError = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { showEmptyError = false }
        } else {
            router.goToScript(topic: trimmed)
        }
    }

    @MainActor
    private func fetchSurpriseTopic() async {
        isLoadingSurprise = true
        do {
            let url = URL(string: "http://127.0.0.1:5001/api/script/create_random_topic")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let (data, _) = try await URLSession.shared.data(for: request)
            struct TopicResponse: Decodable { let topic: String }
            let result = try JSONDecoder().decode(TopicResponse.self, from: data)

            topic = result.topic
            showEmptyError = false
        } catch {
            print("❌ Error fetching surprise topic: \(error)")
            topic = ideaFor(title: suggestedIdeas.randomElement() ?? "The Eye of a Storm")
        }
        isLoadingSurprise = false
    }
}

#Preview {
    ContentView().environment(Router())
}

