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

            VStack(spacing: 14) { // reduced from 18
                // Header
                VStack(spacing: 6) { // reduced from 8
                    Text("My AI Director")
                        .font(.system(size: 30, weight: .bold)) // was 32
                        .foregroundColor(.white)
                    Text("Choose Your Voice")
                        .foregroundColor(.white.opacity(0.9))
                        .font(.title3.bold()) // was title2
                    Text("Step 2 of 4")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))

                    SegmentedToggle(options: ["Female", "Male"], selected: $viewModel.selectedGender)
                        .padding(.top, 6) // was 8
                }

                // Voice Options
                LazyVGrid(columns: columns, spacing: 12) { // reduced from 14
                    ForEach(viewModel.voicesForCurrentGender()) { voice in
                        Button {
                            viewModel.playPreview(for: voice)
                        } label: {
                            HStack(spacing: 6) { // reduced from 8
                                if viewModel.previewingVoiceId == voice.id {
                                    Image(systemName: "waveform.circle.fill")
                                        .foregroundColor(.white)
                                } else {
                                    Image(systemName: "speaker.wave.2.fill")
                                        .foregroundColor(.white.opacity(0.85))
                                }
                                Text(voice.label)
                                    .font(.system(size: 16)) // was subheadline
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                            }
                            .padding(.vertical, 8) // was 10
                            .frame(maxWidth: .infinity)
                            .background(viewModel.selectedVoice == voice
                                        ? Color.blue.opacity(0.30)
                                        : Color.black.opacity(0.20))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button("Stop Preview") { viewModel.stopPreview() }
                        }
                    }
                }
                .padding(.top, 10)

                // Script Display
                VStack(alignment: .leading, spacing: 6) { // reduced spacing
                    Text("Generated Script")
                        .foregroundColor(.white.opacity(0.9))
                        .font(.subheadline.bold()) // smaller than headline

                    ScrollView {
                        Text(project.script)
                            .foregroundColor(.white)
                            .font(.system(size: 16)) // was body
                            .padding(8) // was 12
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.black.opacity(0.25))
                            .cornerRadius(10)
                    }
                    .frame(height: 120) // was 140
                }
                .padding(.top, 10)

                // Generate / Regenerate
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
                    .frame(maxWidth: 260) // narrower
                } else {
                    Button {
                        Task {
                            await viewModel.generateVoice(
                                projectId: project.backendId ?? "",
                                script: project.script
                            )
                        }
                    } label: {
                        HStack(spacing: 4) {
                            if viewModel.isGenerating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "arrow.clockwise")
                            }
                            Text(viewModel.isGenerating ? "Regenerating…" : "Regenerate Voice")
                        }
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.vertical, 6)
                    }
                    .disabled(viewModel.isGenerating)
                }

                // Player + Continue
                if let audioURL = viewModel.audioURL {
                    VStack(spacing: 8) { // reduced spacing
                        AudioPlayerView(audioURL: audioURL)
                            .frame(height: 44) // smaller player

                        PrimaryGradientButton(title: "Continue to Images", isLoading: false) {
                            var updated = project
                            updated.voiceId = viewModel.selectedVoice.id
                            updated.audioURL = viewModel.audioURL?.absoluteString
                            updated.progressStep = .image
                            projectViewModel.upsertAndNavigate(updated) {
                                router.goToImages(project: $0)
                            }
                        }
                        .padding(.top, 15)
                        .frame(maxWidth: 260)
                    }
                    .padding(.top, 6)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16) // was 20
            .padding(.top, 14) // was 20
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
