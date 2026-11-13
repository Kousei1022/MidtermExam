import Foundation
import SwiftData

@Model
final class WorkoutModel {
    @Attribute(.unique) var id: UUID
    var user: UserModel?
    var workoutName: String
    var workoutType: String
    var date: Date
    var duration: Int
    var sets: Int
    var repetitions: Int
    var notes: String
    var isCompleted: Bool

    init(
        id: UUID = UUID(),
        user: UserModel? = nil,
        workoutName: String,
        workoutType: String,
        date: Date,
        duration: Int,
        sets: Int,
        repetitions: Int,
        notes: String = "",
        isCompleted: Bool = false
    ) {
        self.id = id
        self.user = user
        self.workoutName = workoutName
        self.workoutType = workoutType
        self.date = date
        self.duration = duration
        self.sets = sets
        self.repetitions = repetitions
        self.notes = notes
        self.isCompleted = isCompleted
    }
}
