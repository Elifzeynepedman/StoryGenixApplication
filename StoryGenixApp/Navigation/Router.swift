//
//  Router.swift
//  StoryGenixApp
//
//  Created by Elif Edman on 29.06.2025.
//

import SwiftUI
import Observation

enum Route: Hashable {
    case script(topic: String)
    case voice(script: String)
    case images(script: String)
    case videopreview

}

@Observable
class Router {
    var path = NavigationPath()
    func goToScript(topic: String) { path.append(Route.script(topic: topic)) }
    func goToVoice(script: String) { path.append(Route.voice(script: script)) }
    func goToImages(script: String) { path.append(Route.images(script: script)) }
    func goToVideoPreview() { path.append(Route.videopreview) }


}
