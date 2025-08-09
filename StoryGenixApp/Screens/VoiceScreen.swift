//
//  VoiceScreen.swift
//  StoryGenix
//

import SwiftUI

struct VoiceScreen: View {
    let project: VideoProject
    @StateObject private var viewModel = VoiceViewModel()

    @Environment(Router.self) private var router
    @EnvironmentObject private var projectViewModel: ProjectsViewModel

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()

            VStack(spacing: 18) {
                // Header
                VStack(spacing: 8) {
                    Text("My AI Director")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    Text("Choose Your Voice")
                        .foregroundColor(.white.opacity(0.9))
                        .font(.title2.bold())
                    Text("Step 2 of 4")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))

                    SegmentedToggle(options: ["Female", "Male"], selected: $viewModel.selectedGender)
                        .padding(.top, 8)
                }

                // Voice Options
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(viewModel.voicesForCurrentGender()) { voice in
                        Button {
                            viewModel.playPreview(for: voice) // select + preview (toggle if same)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: viewModel.previewingVoiceId == voice.id
                                      ? "waveform.circle.fill" : "speaker.wave.2.fill")
                                    .foregroundColor(.white)
                                Text(voice.label)
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(viewModel.selectedVoice == voice
                                         ? Color.blue.opacity(0.30)
                                         : Color.black.opacity(0.20))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                        .contextMenu { Button("Stop Preview") { viewModel.stopPreview() } }
                    }
                }
                .padding(.top, 12)

                // Script Display
                VStack(alignment: .leading, spacing: 8) {
                    Text("Generated Script")
                        .foregroundColor(.white.opacity(0.9))
                        .font(.headline)

                    ScrollView {
                        Text(project.script)
                            .foregroundColor(.white)
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.black.opacity(0.25))
                            .cornerRadius(12)
                    }
                    .frame(height: 140)
                }
                .padding(.top, 12)

                // Generate / Regenerate (text-only button feel, but robust)
                if viewModel.audioURL == nil {
                    PrimaryGradientButton(title: "Generate Voice", isLoading: viewModel.isGenerating) {
                        Task {
                            await viewModel.generateVoice(
                                projectId: project.backendId ?? "",
                                script: project.script
                            )
                        }
                    }
                    .disabled(viewModel.isGenerating)
                    .frame(maxWidth: 300)
                } else {
                    Button {
                        Task {
                            await viewModel.generateVoice(
                                projectId: project.backendId ?? "",
                                script: project.script
                            )
                        }
                    } label: {
                        HStack(spacing: 6) {
                            if viewModel.isGenerating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "arrow.clockwise")
                            }
                            Text(viewModel.isGenerating ? "Regenerating Voice…" : "Regenerate Voice")
                        }
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.vertical, 6)
                    }
                    .disabled(viewModel.isGenerating)
                }

                // Player + Continue
                if let audioURL = viewModel.audioURL {
                    VStack(spacing: 12) {
                        AudioPlayerView(audioURL: audioURL)

                        PrimaryGradientButton(title: "Continue to Images", isLoading: false) {
                            var updated = project
                            updated.voiceId = viewModel.selectedVoice.id
                            updated.audioURL = audioURL.absoluteString
                            updated.progressStep = .image
                            projectViewModel.upsertAndNavigate(updated) {
                                router.goToImages(project: $0)
                            }
                        }
                        .frame(maxWidth: 300)
                    }
                    .padding(.top, 1)
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .onChange(of: viewModel.selectedGender) {
            viewModel.resetVoice()
        }
        .onDisappear {
            viewModel.stopPreview()
            NotificationCenter.default.post(name: .stopAllAudio, object: nil)
        }
    }
}
