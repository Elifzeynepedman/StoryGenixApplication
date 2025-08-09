

import SwiftUI

struct FeedbackModalView: View {
    let title: String
    let placeholder: String
    let emoji: String
    let onSubmit: (String) -> Void
    @Binding var isPresented: Bool

    @State private var message = ""

    var body: some View {
        ZStack {
            // ✅ Same Background as Main Screen
            Color("Background")
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // ✅ Title
                Text("\(emoji)  \(title)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(radius: 6)

                // ✅ Input Box Styled Like ContentView
                ZStack(alignment: .topLeading) {
                    if message.isEmpty {
                        Text(placeholder)
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.horizontal, 14)
                            .padding(.top, 14)
                    }

                    TextEditor(text: $message)
                        .scrollContentBackground(.hidden)
                        .frame(height: 120)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(
                            ZStack {
                                Color.black.opacity(0.3)
                                LinearGradient(
                                    colors: [
                                        Color("BackgroundGradientDark").opacity(0.2),
                                        Color("BackgroundGradientPurple").opacity(0.15)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                }
                .padding(.horizontal, 24)

                // ✅ Buttons
                VStack(spacing: 14) {
                    // Submit with Primary Gradient
                    Button(action: submitAction) {
                        Text("Submit")
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
                            .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 4)
                    }

                    // Cancel Button with Glass Look
                    Button(action: { isPresented = false }) {
                        Text("Cancel")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.85))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                }
                .padding(.horizontal, 24)

                Spacer()
            }
            .padding(.top, 60)
        }
        .transition(.move(edge: .bottom))
        .animation(.spring(), value: isPresented)
    }

    private func submitAction() {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            onSubmit(trimmed)
            isPresented = false
        }
    }
}
