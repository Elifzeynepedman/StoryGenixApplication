import Foundation

struct VideoProject: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var script: String
    var thumbnail: String
    var scenes: [VideoScene]
    var sceneDescriptions: [String]
    var imagePrompts: [String]
    var klingPrompts: [String] // ✅ Added property
    var isCompleted: Bool
    var progressStep: Int
    var currentSceneIndex: Int? = nil
    var selectedImageIndices: [Int: Int] = [:]

    init(
        id: UUID = UUID(),
        title: String,
        script: String = "",
        thumbnail: String,
        scenes: [VideoScene] = [],
        sceneDescriptions: [String] = [],
        imagePrompts: [String] = [],
        klingPrompts: [String] = [], // ✅ Added parameter
        isCompleted: Bool,
        progressStep: Int,
        currentSceneIndex: Int? = nil
    ) {
        self.id = id
        self.title = title
        self.script = script
        self.thumbnail = thumbnail
        self.scenes = scenes
        self.sceneDescriptions = sceneDescriptions
        self.imagePrompts = imagePrompts
        self.klingPrompts = klingPrompts // ✅ FIX HERE
        self.isCompleted = isCompleted
        self.progressStep = progressStep
        self.currentSceneIndex = currentSceneIndex
    }
}
