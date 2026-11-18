import Foundation
import SwiftData

@Model
final class WorkoutModel {
    @Attribute(.unique) var id: UUID
    var user: UserModel?
    var workoutName: String
    var workoutType: String
    var date: Date
    var endDate: Date?
    var duration: Int
    var sets: Int
    var repetitions: Int
    var notes: String
    var isCompleted: Bool
    var sessionTitle: String

    @Relationship(deleteRule: .cascade, inverse: \WorkoutExerciseModel.workout)
    var exercises: [WorkoutExerciseModel] = []

    var totalExerciseCount: Int {
        exercises.count
    }

    var totalSetsCount: Int {
        exercises.reduce(0) { $0 + $1.sets.count }
    }

    var totalVolume: Int {
        exercises.reduce(0) { $0 + $1.totalVolume }
    }

    var totalRepsCount: Int {
        exercises.reduce(0) { partialResult, exercise in
            partialResult + exercise.sets.reduce(0) { $0 + $1.repetitions }
        }
    }

    var completedSetCount: Int {
        exercises.reduce(0) { partialResult, exercise in
            partialResult + exercise.sets.filter { ($0.isCompleted ?? false) }.count
        }
    }

    init(
        id: UUID = UUID(),
        user: UserModel? = nil,
        workoutName: String,
        workoutType: String = "Training",
        date: Date,
        endDate: Date? = nil,
        duration: Int = 0,
        sets: Int = 0,
        repetitions: Int = 0,
        notes: String = "",
        isCompleted: Bool = false,
        sessionTitle: String = "",
        exercises: [WorkoutExerciseModel] = []
    ) {
        self.id = id
        self.user = user
        self.workoutName = workoutName
        self.workoutType = workoutType
        self.date = date
        self.endDate = endDate
        self.duration = duration
        self.sets = sets
        self.repetitions = repetitions
        self.notes = notes
        self.isCompleted = isCompleted
        self.sessionTitle = sessionTitle.isEmpty ? workoutName : sessionTitle
        self.exercises = exercises
    }

    func refreshDerivedSummary() {
        sets = totalSetsCount
        repetitions = totalRepsCount
        duration = max(duration, exercises.reduce(0) { $0 + $1.duration })
        if workoutName.isEmpty {
            workoutName = sessionTitle.isEmpty ? "Workout Session" : sessionTitle
        }
        if sessionTitle.isEmpty {
            sessionTitle = workoutName
        }
    }
}

@Model
final class WorkoutExerciseModel {
    @Attribute(.unique) var id: UUID
    var workout: WorkoutModel?
    var exerciseName: String
    var muscleGroup: String
    var notes: String
    var duration: Int
    var distance: Double
    var orderIndex: Int
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \WorkoutSetModel.exercise)
    var sets: [WorkoutSetModel] = []

    var totalVolume: Int {
        sets.reduce(0) { total, set in
            total + Int(Double(set.weight) * Double(set.repetitions))
        }
    }

    init(
        id: UUID = UUID(),
        workout: WorkoutModel? = nil,
        exerciseName: String,
        muscleGroup: String = "Full Body",
        notes: String = "",
        duration: Int = 0,
        distance: Double = 0,
        orderIndex: Int = 0,
        createdAt: Date = Date(),
        sets: [WorkoutSetModel] = []
    ) {
        self.id = id
        self.workout = workout
        self.exerciseName = exerciseName
        self.muscleGroup = muscleGroup
        self.notes = notes
        self.duration = duration
        self.distance = distance
        self.orderIndex = orderIndex
        self.createdAt = createdAt
        self.sets = sets
    }
}

@Model
final class WorkoutSetModel {
    @Attribute(.unique) var id: UUID
    var exercise: WorkoutExerciseModel?
    var setNumber: Int
    var weight: Double
    var repetitions: Int
    var duration: Int
    var distance: Double
    var notes: String
    var isCompleted: Bool?

    init(
        id: UUID = UUID(),
        exercise: WorkoutExerciseModel? = nil,
        setNumber: Int,
        weight: Double = 0,
        repetitions: Int = 0,
        duration: Int = 0,
        distance: Double = 0,
        notes: String = "",
        isCompleted: Bool? = false
    ) {
        self.id = id
        self.exercise = exercise
        self.setNumber = setNumber
        self.weight = weight
        self.repetitions = repetitions
        self.duration = duration
        self.distance = distance
        self.notes = notes
        self.isCompleted = isCompleted
    }
}
