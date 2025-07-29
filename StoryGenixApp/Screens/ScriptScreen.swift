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
            Image("BackgroundImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Header
                Text("StoryGenIX")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)

                Text("Choose your script")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 10)

                // Toggle
                SegmentedToggle(options: ["Auto-Generated", "Write My Own"], selected: $mode)
                    .padding(.horizontal, 20)

                // ✅ Script Display Area
                ZStack(alignment: .topLeading) {
                    Color("DarkTextColor")
                        .cornerRadius(16)

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
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.top, 12)
                                .padding(.horizontal, 8)
                                .font(.system(size: 16))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        TextEditor(text: $customScriptText)
                            .foregroundColor(.white)
                            .padding(8)
                            .scrollContentBackground(.hidden)
                    }
                }
                .frame(height: 350)
                .padding(.horizontal, 20)

                // Buttons
                SecondaryActionButton(title: "Continue to Voice") {
                    var project = VideoProject(
                        title: topic,
                        script: currentScript,
                        thumbnail: "defaultThumbnail",
                        sceneDescriptions: viewModel.scenes,                   isCompleted: false,
                        progressStep: 1
                    )

                    if projectViewModel.project(for: project.id) == nil {
                        projectViewModel.addProject(project)
                    } else {
                        projectViewModel.updateProject(project)
                    }

                    router.goToVoice(project: project)
                }



                if useAIGeneration {
                    Button {
                        Task { await viewModel.generateScript(for: topic) }
                    } label: {
                        if viewModel.isLoading {
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
