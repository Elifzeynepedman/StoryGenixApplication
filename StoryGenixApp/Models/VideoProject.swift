import Foundation

enum ProgressStep: Int, Codable {
    case script = 1
    case voice = 2
    case image = 3
    case video = 4
    case completed = 5
}

struct VideoProject: Identifiable, Codable, Hashable {
    let id: UUID
    var backendId: String?
    var title: String
    var script: String
    var thumbnail: String
    var scenes: [VideoScene]
    var sceneDescriptions: [String]
    var imagePrompts: [String]
    var klingPrompts: [String]
    var voiceId: String?
    var audioURL: String?
    var selectedImageIndices: [Int: Int]
    var videoURL: String?
    var isCompleted: Bool
    var progressStep: ProgressStep
    var currentSceneIndex: Int?

    init(
        id: UUID = UUID(),
        backendId: String? = nil,
        title: String,
        script: String = "",
        thumbnail: String,
        scenes: [VideoScene] = [],
        sceneDescriptions: [String] = [],
        imagePrompts: [String] = [],
        klingPrompts: [String] = [],
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
        self.sceneDescriptions = sceneDescriptions
        self.imagePrompts = imagePrompts
        self.klingPrompts = klingPrompts
        self.voiceId = voiceId
        self.audioURL = audioURL
        self.selectedImageIndices = selectedImageIndices
        self.videoURL = videoURL
        self.isCompleted = isCompleted
        self.progressStep = progressStep
        self.currentSceneIndex = currentSceneIndex
    }
}
