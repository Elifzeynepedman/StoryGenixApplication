//
//  LanguageSelectionView.swift
//  StoryGenix
//
//  Created by Elif Edman on 3.08.2025.
//

import SwiftUI

struct LanguageSelectionView: View {
    @State private var selectedLanguage: String = "en"
    var onContinue: () -> Void
    
    let languages = [
        ("en", "English"),
        ("fr", "Français"),
        ("es", "Español"),
        ("de", "Deutsch"),
        ("tr", "Türkçe")
    ]
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                Text("🌍 Choose Your Language")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 14) {
                    ForEach(languages, id: \.0) { code, name in
                        Button(action: {
                            withAnimation(.spring()) {
                                selectedLanguage = code
                                UserDefaults.standard.set([code], forKey: "AppleLanguages")
                                UserDefaults.standard.synchronize()
                            }
                        }) {
                            HStack {
                                Text(name)
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                                Spacer()
                                if selectedLanguage == code {
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
                                    .stroke(selectedLanguage == code ? Color("ButtonGradient2") : Color.clear, lineWidth: 2)
                            )
                            .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 4)
                        }
                        .scaleEffect(selectedLanguage == code ? 1.02 : 1)
                        .animation(.spring(), value: selectedLanguage)
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
                .disabled(selectedLanguage.isEmpty)
                .opacity(selectedLanguage.isEmpty ? 0.5 : 1)
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
    }
}
