//
//  LanguageSelectionScreen.swift
//  StoryGenix
//
//  Created by Elif Edman on 3.08.2025.
//

import SwiftUI

struct LanguageSelectionScreen: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("contentLanguage") private var selectedLanguage: String = "en"

    let languages: [(code: String, name: String)] = [
        ("en", "English"),
        ("fr", "Français"),
        ("es", "Español"),
        ("de", "Deutsch"),
        ("tr", "Türkçe")
    ]

    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text(NSLocalizedString("choose_language", comment: ""))
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .padding(.top, 40)

                ForEach(languages, id: \.code) { lang in
                    Button(action: {
                        selectedLanguage = lang.code
                        dismiss()
                    }) {
                        HStack {
                            Text(lang.name)
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .medium))

                            Spacer()

                            if selectedLanguage == lang.code {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }

                Spacer()
            }
            .padding(.horizontal)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    LanguageSelectionScreen()
}
