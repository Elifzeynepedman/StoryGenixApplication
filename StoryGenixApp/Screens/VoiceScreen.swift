//
//  VoiceScreen.swift
//  StoryGenixApp
//
//  Created by Elif Edman on 29.06.2025.
//
import SwiftUI
import AVFoundation

struct VoiceScreen: View {
    let script: String

    @State private var selectedGender = "Female"
    @State private var selectedVoice = "Jennie"
    @State private var isGenerating = false
    @State private var audioURL: URL? = nil
    @Environment(Router.self) private var router

    let femaleVoices = ["Jennie", "Elif", "Sarah", "Katie"]
    let maleVoices = ["Brian", "David", "Alex", "Mike"]
    let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]

    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 28) {
                headerSection
                voiceGridSection
                PrimaryGradientButton(title: "Generate Voice", isLoading: isGenerating, action: generateVoice)
                    .frame(maxWidth: 370)
                    .disabled(isGenerating)

                if audioURL != nil {
                    audioPlayerSection
                }
                Spacer()
            }
            .frame(width: 390)
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .onChange(of: selectedGender) {
            selectedVoice = selectedGender == "Female" ? "Jennie" : "Brian"
        }
    }

    var headerSection: some View {
        VStack(spacing: 8) {
            Spacer().frame(height: 16)
            Text("VidGenius")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
            Text("Choose Your Voice")
                .foregroundStyle(.white)
                .font(.system(size: 34, weight: .bold))
                .multilineTextAlignment(.center)
            SegmentedToggle(options: ["Female", "Male"], selected: $selectedGender)
                .frame(width: 280, height: 35)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    var voiceGridSection: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(selectedGender == "Female" ? femaleVoices : maleVoices, id: \.self) { voice in
                Button(action: { selectedVoice = voice }) {
                    HStack(spacing: 8) {
                        Text(voice)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                        Image(systemName: "waveform")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 18)
                            .foregroundColor(.white)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(selectedVoice == voice ? .purple : Color.white.opacity(0.3), lineWidth: 1.5)
                            .background(selectedVoice == voice ? Color.white.opacity(0.1) : Color.clear)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
        .frame(maxWidth: 370)
    }

    var audioPlayerSection: some View {
        VStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("DarkText"))
                .frame(height: 140)
                .overlay(
                    ScrollView {
                        Text(script)
                            .padding(20)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                )
                .frame(maxWidth: 370)

            HStack {
                Text("0:00")
                    .foregroundColor(.white)
                    .font(.caption)
                Slider(value: .constant(0.5))
                    .accentColor(.blue)
                Text("1:34")
                    .foregroundColor(.white)
                    .font(.caption)
            }
            .frame(maxWidth: 350)
            
            SecondaryActionButton(title: "Continue to Images") {
                router.goToImages(script: script)
            }

            PlainTextButton(title: "Regenrate Voice", action: generateVoice)
                .disabled(isGenerating)
                .padding(.bottom, 40)
                .padding(.top, -10)
        }
    }

    func generateVoice() {
        isGenerating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            audioURL = URL(string: "https://example.com/audio/\(selectedVoice).mp3")
            isGenerating = false
        }
    }
}

#Preview {
    VoiceScreen(
        script: "This is the sample script that will be generated and bla bla bla bla bla.")
        .withRouter()
}
