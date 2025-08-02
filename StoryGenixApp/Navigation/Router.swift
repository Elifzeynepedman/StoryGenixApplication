import SwiftUI
import Observation

enum Route: Hashable {
    case home
    case script(topic: String)
    case voice(project: VideoProject)
    case images(project: VideoProject)
    case videopreview(project: VideoProject)
    case videocomplete(project: VideoProject)
    case appSettings
    case contact
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
    
    func goToVoice(project: VideoProject) {
        path.append(Route.voice(project: project))
    }

    func goToImages(project: VideoProject) {
        path.append(Route.images(project: project))
    }

    func goToVideoPreview(project: VideoProject) {
        path.append(Route.videopreview(project: project))
    }

    func goToVideoComplete(project: VideoProject) {
        path.append(Route.videocomplete(project: project))
    }
    func goToAppSettings() {
        path.append(Route.appSettings)
    }

    func goToContact() {
        path.append(Route.contact)
    }

    
    func goToStep(for project: VideoProject) {
        switch project.progressStep {
        case .script:
            goToScript(topic: project.title)
        case .voice:
            goToVoice(project: project)
        case .image:
            goToImages(project: project)
        case .video:
            goToVideoPreview(project: project)
        case .completed:
            goToVideoComplete(project: project)
        }
    }



}

