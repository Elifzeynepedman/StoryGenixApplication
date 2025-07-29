import SwiftUI
import Observation

enum ProgressStep: Int {
    case script = 1
    case voice = 2
    case image = 3
    case video = 4
}

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
        case 1:
            goToVoice(project: project)
        case 2:
            goToImages(project: project)
        case 3:
            goToVideoPreview(project: project)
        case 4:
            goToVideoComplete(project: project)
        default:
            goToScript(topic: project.title)
        }
    }


}

