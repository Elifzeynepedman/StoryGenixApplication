import SwiftUI

struct ScriptScreen: View {
    let project: VideoProject

    @State private var mode = "Auto-Generated"
    @State private var customScriptText = ""
    @StateObject private var viewModel = ScriptLogicViewModel()
    @State private var aiText: String = ""

    @Environment(Router.self) private var router
    @EnvironmentObject private var projectViewModel: ProjectsViewModel

    private var useAIGeneration: Bool { mode == "Auto-Generated" }
    private var currentScript: String { useAIGeneration ? aiText : customScriptText }

    private var mainButtonText: String {
        useAIGeneration && aiText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ? "Generate Script"
        : "Continue to Voice"
    }

    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()

            VStack(spacing: 16) {
                header

                SegmentedToggle(options: ["Auto-Generated", "Write My Own"], selected: $mode)
                    .padding(.horizontal, 24)

                if useAIGeneration {
                    Text("⚡ Generation usually takes ~20 seconds")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                scriptBox
                    .frame(maxHeight: .infinity)
                    .padding(.horizontal, 24)

                // Buttons remain visible; loading state handled inside scriptBox + disabled here
                mainActionButton
                    .padding(.horizontal)

                if useAIGeneration && !aiText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    regenerateButton
                }
            }
        }
        .ignoresSafeArea(.keyboard)
        .contentShape(Rectangle())
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .onAppear {
            aiText = viewModel.displayScript
        }
        .onChange(of: viewModel.displayScript) { newValue in
            aiText = newValue
        }
        .onChange(of: mode) { newMode in
            if newMode == "Auto-Generated" {
                aiText = viewModel.displayScript
            }
        }
    }

    // MARK: - UI

    private var header: some View {
        VStack(spacing: 6) {
            Text("My AI Director")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
            Text("Choose your script")
                .font(.title2.bold())
                .foregroundColor(.white.opacity(0.9))
            Text("Step 1 out of 4")
                .font(.system(size: 12, weight: .light))
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(.top, 40)
    }

    private var scriptBox: some View {
        ZStack {
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

            if viewModel.isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                    Text("Generating script...")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.subheadline)
                }
                .padding(16)
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.system(size: 16))
                    .padding(16)
            } else if useAIGeneration {
                TextEditor(text: $aiText)
                    .scrollContentBackground(.hidden)
                    .foregroundColor(.white)
                    .padding(12)
                    .overlay(alignment: .topLeading) {
                        if aiText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text("Edit your AI-generated script…")
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 14)
                        }
                    }
            } else {
                TextEditor(text: $customScriptText)
                    .scrollContentBackground(.hidden)
                    .foregroundColor(.white)
                    .padding(12)
                    .overlay(alignment: .topLeading) {
                        if customScriptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text("Write your script here...")
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 14)
                        }
                    }
            }
        }
    }

    private var mainActionButton: some View {
        Button {
            if useAIGeneration && aiText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Task {
                    guard let pid = project.backendId, !pid.isEmpty else {
                        viewModel.errorMessage = "This project isn’t linked to the backend yet. Please go back and start a new project."
                        return
                    }
                    await viewModel.generateScript(for: project.title, projectId: pid)
                }
            } else {
                Task { await continueToVoice() }
            }
        } label: {
            Text(mainButtonText)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
        }
        .background(
            LinearGradient(
                colors: [Color("ButtonGradient1"), Color("ButtonGradient2"), Color("ButtonGradient3")],
                startPoint: .leading, endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 4)
        .disabled(
            viewModel.isLoading ||
            (!useAIGeneration && customScriptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        )
    }

    private var regenerateButton: some View {
        Button {
            Task {
                guard let pid = project.backendId, !pid.isEmpty else {
                    viewModel.errorMessage = "Missing project link. Please start a new project."
                    return
                }
                await viewModel.generateScript(for: project.title, projectId: pid)
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "arrow.clockwise")
                Text("Regenerate Script")
            }
            .font(.subheadline)
            .foregroundColor(.white.opacity(0.9))
        }
        .disabled(viewModel.isLoading)
        .padding(.top, 4)
        .padding(.bottom, 8)
    }

    // MARK: - Navigation

    private func continueToVoice() async {
        var updatedProject = project
        updatedProject.script = currentScript
        updatedProject.scenes = viewModel.scenes.map {
            VideoScene(sceneText: $0.text, prompt: $0.imagePrompt)
        }
        updatedProject.progressStep = .voice

        projectViewModel.upsertAndNavigate(updatedProject) {
            router.goToVoice(project: $0)
        }
    }
}
