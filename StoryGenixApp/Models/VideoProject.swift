import Foundation

enum ProgressStep: Int, Codable {
    case script = 1
    case voice = 2
    case image = 3
    case video = 4
    case completed = 5

    init(status: String) {
        switch status {
        case "script_created": self = .script
        case "voice_created": self = .voice
        case "image_created": self = .image
        case "video_created": self = .video
        case "completed": self = .completed
        default: self = .script // fallback
        }
    }
}

struct VideoProject: Identifiable, Codable, Hashable {
    let id: UUID
    var backendId: String?        // backend project ID from API
    var title: String             // project title
    var script: String            // full script
    var thumbnail: String         // cover image (can be placeholder)
    var scenes: [VideoScene]      // each scene (text + prompt)
    var voiceId: String?          // selected voice
    var audioURL: String?         // generated voice audio
    var selectedImageIndices: [Int: Int] // per-scene selected image index
    var videoURL: String?         // final video file
    var isCompleted: Bool         // flag for completion
    var progressStep: ProgressStep
    var currentSceneIndex: Int?

    init(
        id: UUID = UUID(),
        backendId: String? = nil,
        title: String,
        script: String = "",
        thumbnail: String,
        scenes: [VideoScene] = [],
        voiceId: String? = nil,
        audioURL: String? = nil,
        selectedImageIndices: [Int: Int] = [:],
        videoURL: String? = nil,
        isCompleted: Bool = false,
        progressStep: ProgressStep = .script,
        currentSceneIndex: Int? = nil
    ) {
        self.id = id
        self.backendId = backendId
        self.title = title
        self.script = script
        self.thumbnail = thumbnail
        self.scenes = scenes
        self.voiceId = voiceId
        self.audioURL = audioURL
        self.selectedImageIndices = selectedImageIndices
        self.videoURL = videoURL
        self.isCompleted = isCompleted
        self.progressStep = progressStep
        self.currentSceneIndex = currentSceneIndex
    }
}
