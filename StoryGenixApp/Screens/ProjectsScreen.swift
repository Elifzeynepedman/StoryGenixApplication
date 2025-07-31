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

    private let gridColumns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("My AI Director")
                    .font(.system(size: 36, weight: .bold))
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
                                        UnfinishedProjectCard(project: project) {
                                            viewModel.deleteProject(project)
                                        }
                                        .padding(.horizontal, 20)
                                    }
                                }
                            }

                            // ✅ Completed Section
                            if !completedProjects.isEmpty {
                                Text("Previous Projects")
                                    .font(.title3.bold())
                                    .foregroundColor(.white)
                                    .padding(.horizontal)

                                LazyVGrid(columns: gridColumns, spacing: 20) {
                                    ForEach(completedProjects) { project in
                                        CompletedProjectCard(project: project) {
                                            viewModel.deleteProject(project)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
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
}

#Preview {
    ProjectsScreen()
        .environmentObject(ProjectsViewModel())
}
