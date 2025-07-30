import SwiftUI


struct ScriptScreen: View {
    let topic: String
    @State private var mode = "Auto-Generated"
    @State private var customScriptText = ""
    @StateObject private var viewModel = ScriptLogicViewModel()

    @Environment(Router.self) private var router
    @EnvironmentObject private var projectViewModel: ProjectsViewModel

    private var useAIGeneration: Bool { mode == "Auto-Generated" }
    private var currentScript: String {
        useAIGeneration ? viewModel.displayScript : customScriptText
    }

    var body: some View {
        ZStack {
            // ✅ Background
            Image("BackgroundImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // ✅ Header
                VStack(spacing: 6) {
                    Text("StoryGenix")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    Text("Choose your script")
                        .font(.title2.bold())
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.top, 40)

                // ✅ Toggle for Mode
                SegmentedToggle(options: ["Auto-Generated", "Write My Own"], selected: $mode)
                    .padding(.horizontal, 24)

                // ✅ Script Display / Input Box
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.black.opacity(0.3))
                        .overlay(
                            LinearGradient(
                                colors: [
                                    Color("BackgroundGradientDark").opacity(0.15),
                                    Color("BackgroundGradientPurple").opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )

                    if useAIGeneration {
                        ScrollView {
                            Text(viewModel.displayScript.isEmpty ? "Generating script..." : viewModel.displayScript)
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    } else {
                        if customScriptText.isEmpty {
                            Text("Write your script here...")
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.top, 14)
                                .padding(.horizontal, 12)
                        }

                        TextEditor(text: $customScriptText)
                            .scrollContentBackground(.hidden)
                            .foregroundColor(.white)
                            .padding(12)
                    }
                }
                .frame(height: 350)
                .padding(.horizontal, 24)
                .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)

                // ✅ Continue Button (Gradient)
                Button(action: {
                    var project = VideoProject(
                        title: topic,
                        script: currentScript,
                        thumbnail: "defaultThumbnail",
                        sceneDescriptions: viewModel.scenes.map { $0.text },
                        imagePrompts: viewModel.scenes.map { $0.imagePrompt },
                        klingPrompts: viewModel.scenes.map { $0.klingPrompt },
                        isCompleted: false,
                        progressStep: 1
                    )

                    if projectViewModel.project(for: project.id) == nil {
                        projectViewModel.addProject(project)
                    } else {
                        projectViewModel.updateProject(project)
                    }

                    router.goToVoice(project: project)
                }) {
                    Text("Continue to Voice")
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

                // ✅ Regenerate Button (for Auto Mode)
                if useAIGeneration {
                    Button {
                        Task { await viewModel.generateScript(for: topic) }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Regenerate Script")
                            }
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    .padding(.top, 4)
                }

                Spacer()
            }
        }
        .onAppear {
            if useAIGeneration && viewModel.script.isEmpty {
                Task { await viewModel.generateScript(for: topic) }
            }
        }
    }
}

#Preview {
    ScriptScreen(topic: "How eyes work")
        .environment(Router())
        .environmentObject(ProjectsViewModel())
}
