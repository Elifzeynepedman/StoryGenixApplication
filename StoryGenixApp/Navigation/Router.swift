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
    case voice(script: String, topic: String)
    case images(script: String, topic: String)
    case videopreview(script: String, topic: String, projectID: UUID)
    case videocomplete(project: VideoProject)
}

@Observable
class Router {
    var path = NavigationPath()
    
    func goToHome() {
        path = NavigationPath()
    }
    func goToScript(topic: String) {
        path.append(Route.script(topic: topic))
    }
    func goToVoice(script: String, topic: String) {
        path.append(Route.voice(script: script, topic: topic))
    }
    func goToImages(script: String, topic: String) {
        path.append(Route.images(script: script, topic: topic))
    }
    func goToVideoPreview(script: String, topic: String, projectID: UUID) {
        path.append(Route.videopreview(script: script, topic: topic, projectID: projectID))
    }
    func goToVideoComplete(project: VideoProject) {
        path.append(Route.videocomplete(project: project))
    }


}
