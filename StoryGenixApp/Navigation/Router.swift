//
//  Router.swift
//  StoryGenixApp
//
//  Created by Elif Edman on 29.06.2025.
//

import SwiftUI
import Observation

enum Route: Hashable {
    case home
    case script(topic: String)
    case voice(script: String)
    case images(script: String)
    case videopreview(script: String)
    case videocomplete


}

@Observable
class Router {
    var path = NavigationPath()
    func goToHome() {
        path = NavigationPath() // this triggers showing ContentView directly
    }
    func goToScript(topic: String) { path.append(Route.script(topic: topic)) }
    func goToVoice(script: String) { path.append(Route.voice(script: script)) }
    func goToImages(script: String) { path.append(Route.images(script: script)) }
    func goToVideoPreview(script: String) { path.append(Route.videopreview(script: script)) }
    func goToVideoComplete() { path.append(Route.videocomplete) }

}
