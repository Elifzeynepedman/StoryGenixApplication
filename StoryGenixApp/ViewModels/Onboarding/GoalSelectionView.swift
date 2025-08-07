//
//  GoalSelectionView.swift
//  StoryGenix
//
//  Created by Elif Edman on 3.08.2025.
//

import SwiftUI

struct GoalSelectionView: View {
    @State private var selectedGoal: String? = nil
    var onContinue: () -> Void
    
    let goals = [
        "Create Social Media Content",
        "Educational / Learning Videos",
        "Tell a Story with AI"
    ]
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                Text("🎯 What's Your Goal?")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 14) {
                    ForEach(goals, id: \.self) { goal in
                        Button(action: {
                            withAnimation(.spring()) {
                                selectedGoal = goal
                            }
                        }) {
                            HStack {
                                Text(goal)
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                                Spacer()
                                if selectedGoal == goal {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(Color("ButtonGradient2"))
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(selectedGoal == goal ? Color("ButtonGradient2") : Color.clear, lineWidth: 2)
                            )
                            .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 4)
                        }
                        .scaleEffect(selectedGoal == goal ? 1.02 : 1)
                        .animation(.spring(), value: selectedGoal)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color("ButtonGradient1"), Color("ButtonGradient2"), Color("ButtonGradient3")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .shadow(color: Color.black.opacity(0.4), radius: 6, x: 0, y: 4)
                }
                .disabled(selectedGoal == nil)
                .opacity(selectedGoal == nil ? 0.5 : 1)
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
    }
}
