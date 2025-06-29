//
//  ContentView.swift
//  StoryGenixApp
//
//  Created by Elif Edman on 29.06.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var topic: String = ""
    @Environment(Router.self) private var router

    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            VStack(spacing: 4) {
                HStack {
                    Text("StoryGenIX")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(.white)
                    Image(systemName: "star.fill")
                        .foregroundStyle(Color.pink)
                }
                HStack (spacing: 30) {
                    Text("One Topic")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                    Text("Script, Voice, Images, Video")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                }
                .padding(.bottom, 60)
                VStack(spacing: 14) {
                    Text("What video would you like to create?")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 3)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    HStack {
                        TextField(
                            "",
                            text: $topic,
                            prompt: Text("Type your topic here...").foregroundColor(.white.opacity(0.8))
                        )
                        .padding()
                        .foregroundColor(.white)

                        Image(systemName: "mic.fill")
                            .foregroundStyle(Color.white.opacity(0.85))
                            .padding(.trailing, 12)
                    }
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color("BackgroundGradientDark"),
                                Color("BackgroundGradientPurple"),
                                Color("BackgroundGradientNavy")
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .opacity(0.4)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white, lineWidth: 0.5)
                    )
                    .padding(.horizontal, 30)
                    .padding(.top, -20)
                    Button(action: {
                        if !topic.isEmpty {
                            router.goToScript(topic: topic)
                        }
                    }) {
                        Text("Generate Video")
                            .font(.headline)
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color("ButtonGradient1"),
                                        Color("ButtonGradient2"),
                                        Color("ButtonGradient3")
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(.rect(cornerRadius: 18))
                            .shadow(color: .black.opacity(0.07), radius: 4, x: 0, y: 2)
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 30)
                    Spacer()
                }
                .frame(width: 350, height: 250)
                .padding(.top, 40)
                .background(Color.white.opacity(0.08))
                .cornerRadius(28)
                .padding(.horizontal)
            }
        }
        .frame(maxHeight: .infinity, alignment: .center)
    }
}

#Preview {
    ContentView().withRouter()
}
