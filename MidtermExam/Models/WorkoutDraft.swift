import Foundation

struct ExerciseDraft: Identifiable {
    let id = UUID()
    var name = ""
    var muscleGroup = "Chest"
    var notes = ""
    var duration = 0
    var weight = "0"
    var sets: [SetDraft] = [SetDraft()]
}

struct SetDraft: Identifiable {
    let id = UUID()
    var weight = "0"
    var repetitions = 0
    var duration = 0
    var distance = "0"
    var notes = ""
    var isCompleted = false
}

struct ExerciseLibraryItem: Identifiable {
    var id: String { name }
    let name: String
    let category: String
}
