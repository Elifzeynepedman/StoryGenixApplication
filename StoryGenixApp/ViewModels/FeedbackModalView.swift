
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
            Color("DarkTextColor").opacity(0.8).ignoresSafeArea()

            VStack(spacing: 16) {
                Text("\(emoji)\n\(title)")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)

                TextField(placeholder, text: $message)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .foregroundColor(.white)

                HStack(spacing: 16) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .foregroundColor(.white)

                    Button("Submit") {
                        let trimmed = message.trimmingCharacters(in: .whitespaces)
                        if !trimmed.isEmpty {
                            onSubmit(trimmed)
                            isPresented = false
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .foregroundColor(.white)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.05))
            )
            .padding()
        }
    }
}
