//
//  ProjectsScreen.swift
//  StoryGenix
//
//  Created by Elif Edman on 2.07.2025.
//

import SwiftUI

struct ProjectsScreen: View {
    @EnvironmentObject var viewModel: ProjectsViewModel
    @Environment(Router.self) private var router

    private var unfinishedProjects: [VideoProject] {
        viewModel.allProjects.filter { !$0.isCompleted }
    }

    private var completedProjects: [VideoProject] {
        viewModel.allProjects.filter { $0.isCompleted }
    }

    private let gridColumns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // ✅ Header
                Text("My Projects")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 30)

                if viewModel.allProjects.isEmpty {
                    VStack(spacing: 8) {
                        Text("No Projects Yet")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        Text("Start by creating your first video.")
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.top, 80)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 28) {
                            
                            // ✅ Unfinished Section
                            if !unfinishedProjects.isEmpty {
                                Text("Unfinished Projects")
                                    .font(.title3.bold())
                                    .foregroundColor(.white)
                                    .padding(.horizontal)

                                LazyVStack(spacing: 16) {
                                    ForEach(unfinishedProjects) { project in
                                        VStack(alignment: .leading, spacing: 10) {
                                            Text(project.title)
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            
                                            Text("Status: \(statusLabel(for: project.progressStep))")
                                                .font(.subheadline)
                                                .foregroundColor(.white.opacity(0.7))
                                            
                                            HStack {
                                                Button(action: {
                                                    viewModel.resumeProject(project, using: router)
                                                }) {
                                                    Text("Resume")
                                                        .font(.footnote)
                                                        .foregroundColor(.white)
                                                        .padding(.horizontal, 16)
                                                        .padding(.vertical, 8)
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
                                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                                }
                                                
                                                Spacer()
                                                
                                                Button(action: {
                                                    viewModel.deleteProject(project)
                                                }) {
                                                    Image(systemName: "trash")
                                                        .foregroundColor(.white.opacity(0.8))
                                                        .padding(8)
                                                        .background(Color.black.opacity(0.3))
                                                        .clipShape(Circle())
                                                }
                                            }
                                        }
                                        .padding()
                                        .background(Color.black.opacity(0.3))
                                        .cornerRadius(12)
                                        .padding(.horizontal)
                                    }
                                }
                            }

                            // ✅ Completed Section
                            if !completedProjects.isEmpty {
                                Text("Completed Projects")
                                    .font(.title3.bold())
                                    .foregroundColor(.white)
                                    .padding(.horizontal)

                                LazyVGrid(columns: gridColumns, spacing: 20) {
                                    ForEach(completedProjects) { project in
                                        VStack {
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(height: 120)
                                                .overlay(Text("Thumbnail").foregroundColor(.white))
                                            
                                            Text(project.title)
                                                .font(.footnote)
                                                .foregroundColor(.white)
                                                .lineLimit(1)
                                            
                                            Button("View") {
                                                router.goToVideoComplete(project: project)
                                            }
                                            .font(.caption)
                                            .padding(.vertical, 6)
                                            .frame(maxWidth: .infinity)
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
                                            .cornerRadius(8)
                                        }
                                        .padding(8)
                                        .background(Color.black.opacity(0.3))
                                        .cornerRadius(12)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }

                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func statusLabel(for step: ProgressStep) -> String {
        switch step {
        case .script: return "Script"
        case .voice: return "Voice"
        case .image: return "Images"
        case .video: return "Video Preview"
        case .completed: return "Completed"
        }
    }
}
