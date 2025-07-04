//
//  ProjectsScreen.swift
//  StoryGenix
//
//  Created by Elif Edman on 2.07.2025.
//

import SwiftUI

struct ProjectsScreen: View {
    @EnvironmentObject var viewModel: ProjectsViewModel

    private var unfinishedProjects: [VideoProject] {
        viewModel.allProjects.filter { !$0.isCompleted }
    }

    private var completedProjects: [VideoProject] {
        viewModel.allProjects.filter { $0.isCompleted }
    }

    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("StoryGenix")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 20)

                if viewModel.allProjects.isEmpty {
                    VStack {
                        Text("No Projects Yet")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        Text("Start by creating your first video.")
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.top, 60)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 28) {
                            if !unfinishedProjects.isEmpty {
                                Text("Unfinished Projects")
                                    .font(.title3.bold())
                                    .foregroundColor(.white)
                                    .padding(.horizontal)

                                ForEach(unfinishedProjects) { project in
                                    UnfinishedProjectCard(project: project, onDelete: {
                                        viewModel.deleteProject(project)
                                    })
                                    .padding(.horizontal, 40)
                                }
                            }

                            Text("Previous Projects")
                                .font(.title3.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                                ForEach(completedProjects) { project in
                                    CompletedProjectCard(project: project, onDelete: {
                                        viewModel.deleteProject(project)
                                    })
                                }
                            }
                            .padding(.horizontal, 50)
                        }
                        .padding(.vertical)
                    }
                }

                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    ProjectsScreen()
        .environmentObject(ProjectsViewModel())
}
