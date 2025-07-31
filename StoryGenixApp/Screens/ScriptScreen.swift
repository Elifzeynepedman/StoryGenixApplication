import SwiftUI

struct ScriptScreen: View {
    let topic: String
    
    @State private var mode = "Auto-Generated"
    @State private var customScriptText = ""
    @StateObject private var viewModel = ScriptLogicViewModel()
    @State private var isCreatingProject = false
    @State private var errorMessage: String?
    
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
                // ✅ Header
                VStack(spacing: 6) {
                    Text("My AI Director")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    Text("Choose your script")
                        .font(.title2.bold())
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.top, 40)
                
                // ✅ Mode Toggle
                SegmentedToggle(options: ["Auto-Generated", "Write My Own"], selected: $mode)
                    .padding(.horizontal, 24)
                
                // ✅ Script Box
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
                    
                    if viewModel.isLoading {
                        ProgressView("Generating script...")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.system(size: 16))
                            .padding(16)
                    } else if useAIGeneration {
                        ScrollView {
                            Text(viewModel.displayScript.isEmpty ? "No script yet." : viewModel.displayScript)
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    } else {
                        TextEditor(text: $customScriptText)
                            .scrollContentBackground(.hidden) // ✅ Removes white default background
                            .foregroundColor(.white)
                            .padding(12)
                            .overlay(
                                Group {
                                    if customScriptText.isEmpty {
                                        Text("Write your script here...")
                                            .foregroundColor(.white.opacity(0.6))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 14)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            )
                    }
                }
                .frame(height: 350)
                .padding(.horizontal, 24)
                
                // ✅ Continue Button
                Button(action: {
                    guard !currentScript.isEmpty else { return }
                    Task {
                        await createProjectAndContinue()
                    }
                }) {
                    if isCreatingProject {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
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
                }
                .padding(.horizontal)
                .disabled(currentScript.isEmpty || isCreatingProject)
                
                // ✅ Regenerate Button
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
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.top, 8)
                }
            }
        }
        .onAppear {
            if useAIGeneration && viewModel.script.isEmpty {
                Task { await viewModel.generateScript(for: topic) }
            }
        }
    }
    
    private func createProjectAndContinue() async {
        isCreatingProject = true
        defer { isCreatingProject = false }
        
        do {
            // ✅ 1. Create project
            let projectResponse = try await ApiService.shared.createProject(title: topic, topic: topic)
            let backendId = projectResponse._id
            
            // ✅ 2. Generate script and save scenes in backend
            let scriptResponse = try await ApiService.shared.generateScriptForProject(
                projectId: backendId,
                topic: topic
            )
            
            // ✅ 3. Create local VideoProject
            var newProject = VideoProject(
                id: UUID(),
                backendId: backendId,
                title: topic,
                script: scriptResponse.script,
                thumbnail: "defaultThumbnail",
                sceneDescriptions: scriptResponse.scenes.map { $0.text },
                imagePrompts: scriptResponse.scenes.map { $0.imagePrompt },
                klingPrompts: scriptResponse.scenes.map { $0.klingPrompt },
                isCompleted: false,
                progressStep: 1
            )
            
            // ✅ 4. Save and navigate
            projectViewModel.upsertAndNavigate(newProject) {
                router.goToVoice(project: $0)
            }
        } catch {
            errorMessage = "Failed to create or generate script. Please try again."
            print("Error creating project or generating script: \(error)")
        }
    }


}
