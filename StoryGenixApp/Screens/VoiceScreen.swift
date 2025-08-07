import SwiftUI

struct VoiceScreen: View {
    let project: VideoProject
    @StateObject private var viewModel = VoiceViewModel()

    @Environment(Router.self) private var router
    @EnvironmentObject private var projectViewModel: ProjectsViewModel

    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 18) {
                // ✅ Header
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

                // ✅ Voice Options Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(viewModel.voicesForCurrentGender()) { voice in
                        Button(action: {
                            viewModel.selectedVoice = voice
                        }) {
                            Text(voice.label)
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding(10)
                                .frame(maxWidth: .infinity)
                                .background(viewModel.selectedVoice == voice ? Color.blue.opacity(0.3) : Color.black.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding(.top, 12)

                // ✅ Script Display
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

                // ✅ Generate or Regenerate Button
                if viewModel.audioURL == nil {
                    PrimaryGradientButton(title: "Generate Voice", isLoading: viewModel.isGenerating) {
                        Task {
                            await viewModel.generateVoice(
                                projectId: project.backendId ?? "",
                                script: project.script                            )
                        }
                    }
                    .frame(maxWidth: 300)
                } else {
                    Button {
                        Task {
                            await viewModel.generateVoice(
                                projectId: project.backendId ?? "",
                                script: project.script                            )
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.clockwise")
                            Text("Regenerate Voice")
                        }
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.vertical, 6)
                    }
                }

                // ✅ Audio Player + Continue Button
                if let audioURL = viewModel.audioURL {
                    VStack(spacing: 12) {
                        AudioPlayerView(audioURL: audioURL)

                        PrimaryGradientButton(title: "Continue to Images", isLoading: false) {
                            var updated = project
                            updated.voiceId = viewModel.selectedVoice.id
                            updated.audioURL = viewModel.audioURL?.absoluteString
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
    }
}
