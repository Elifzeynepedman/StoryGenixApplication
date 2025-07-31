import Foundation

struct VideoProject: Identifiable, Codable, Hashable {
    let id: UUID
    var backendId: String? // ✅ Add this property
    var title: String
    var script: String
    var thumbnail: String
    var scenes: [VideoScene]
    var sceneDescriptions: [String]
    var imagePrompts: [String]
    var klingPrompts: [String]
    var isCompleted: Bool
    var progressStep: Int
    var currentSceneIndex: Int? = nil
    var selectedImageIndices: [Int: Int] = [:]

    init(
        id: UUID = UUID(),
        backendId: String? = nil, // ✅ Added parameter
        title: String,
        script: String = "",
        thumbnail: String,
        scenes: [VideoScene] = [],
        sceneDescriptions: [String] = [],
        imagePrompts: [String] = [],
        klingPrompts: [String] = [],
        isCompleted: Bool,
        progressStep: Int,
        currentSceneIndex: Int? = nil
    ) {
        self.id = id
        self.backendId = backendId // ✅ Assign here
        self.title = title
        self.script = script
        self.thumbnail = thumbnail
        self.scenes = scenes
        self.sceneDescriptions = sceneDescriptions
        self.imagePrompts = imagePrompts
        self.klingPrompts = klingPrompts
        self.isCompleted = isCompleted
        self.progressStep = progressStep
        self.currentSceneIndex = currentSceneIndex
    }
}
