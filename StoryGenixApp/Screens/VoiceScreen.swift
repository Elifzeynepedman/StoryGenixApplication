import SwiftUI
import AVFoundation

struct VoiceScreen: View {
    let project: VideoProject

    @State private var selectedGender = "Female"
    @State private var selectedVoice = "Jennie"
    @State private var isGenerating = false
    @State private var audioURL: URL? = nil

    @Environment(Router.self) private var router
    @EnvironmentObject private var projectViewModel: ProjectsViewModel

    let femaleVoices = ["Jennie", "Elif", "Sarah", "Katie"]
    let maleVoices = ["Brian", "David", "Alex", "Mike"]
    let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]

    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 24) {
                headerSection

                // ✅ Voice Selection Grid
                voiceGridSection

                // ✅ Generate Voice Button (Gradient CTA)
                if audioURL == nil {
                    // ✅ Show gradient button for first time
                    PrimaryGradientButton(
                        title: "Generate Voice",
                        isLoading: isGenerating,
                        action: generateVoice
                    )
                    .frame(maxWidth: 340)
                    .disabled(isGenerating)
                } else {
                    // ✅ Replace with text-only button
                    Button {
                        Task { generateVoice() }
                    } label: {
                        if isGenerating {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.clockwise")
                                Text("Regenerate Voice")
                            }
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                        }
                    }
                }


                // ✅ Audio Player Section
                if audioURL != nil {
                    audioPlayerSection
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 30)
        }
        .onChange(of: selectedGender) {
            selectedVoice = selectedGender == "Female" ? "Jennie" : "Brian"
        }
    }

    // ✅ Header Section
    var headerSection: some View {
        VStack(spacing: 8) {
            Text("StoryGenix")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.white)
            Text("Choose Your Voice")
                .foregroundStyle(.white.opacity(0.9))
                .font(.title2.bold())

            SegmentedToggle(options: ["Female", "Male"], selected: $selectedGender)
                .padding(.top, 8)
        }
    }

    // ✅ Voice Grid with Glass Effect
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
                            .frame(height: 16)
                            .foregroundColor(.white)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(
                        ZStack {
                            Color.black.opacity(0.25)
                            if selectedVoice == voice {
                                LinearGradient(
                                    colors: [
                                        Color("ButtonGradient1").opacity(0.3),
                                        Color("ButtonGradient3").opacity(0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            }
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(selectedVoice == voice ? Color("ButtonGradient2") : Color.white.opacity(0.3), lineWidth: 1.5)
                    )
                }
            }
        }
        .frame(maxWidth: 380)
        .padding(.top, 10)
    }

    // ✅ Audio Player with Script Preview
    var audioPlayerSection: some View {
        VStack(spacing: 14) {
            // Glass card for script
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    ScrollView {
                        Text(project.script)
                            .padding(16)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                    }
                )
                .frame(height: 140)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )

            // Playback controls
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
            .padding(.horizontal, 12)

            // Continue button
            Button {
                var updated = project
                updated.progressStep = 2
                projectViewModel.upsertAndNavigate(updated) {
                    router.goToImages(project: $0)
                }
            } label: {
                Text("Continue to Images")
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
            .padding(.top, 10)
        }
        .padding(.top, 16)
    }

    // ✅ Mock Voice Generation
    func generateVoice() {
        isGenerating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            audioURL = URL(string: "https://example.com/audio/\(selectedVoice).mp3")
            isGenerating = false
        }
    }
}

#Preview {
    VoiceScreen(project: VideoProject(title: "Demo Project", script: "Sample script", thumbnail: "defaultThumbnail", isCompleted: false, progressStep: 1))
        .environment(Router())
        .environmentObject(ProjectsViewModel())
}
