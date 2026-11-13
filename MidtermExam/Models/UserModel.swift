import Foundation
import SwiftData

@Model
final class UserModel {
    @Attribute(.unique) var id: UUID
    var fullName: String
    var username: String
    var email: String
    var passwordHash: String
    var height: Double
    var weight: Double
    var fitnessGoal: String
    var profileImageData: Data?
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \WorkoutModel.user)
    var workouts: [WorkoutModel] = []

    @Relationship(deleteRule: .cascade, inverse: \MealModel.user)
    var meals: [MealModel] = []

    @Relationship(deleteRule: .cascade, inverse: \WeightRecordModel.user)
    var weightRecords: [WeightRecordModel] = []

    init(
        id: UUID = UUID(),
        fullName: String,
        username: String,
        email: String,
        passwordHash: String,
        height: Double = 0,
        weight: Double = 0,
        fitnessGoal: String = "Build Muscle",
        profileImageData: Data? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.fullName = fullName
        self.username = username
        self.email = email.lowercased()
        self.passwordHash = passwordHash
        self.height = height
        self.weight = weight
        self.fitnessGoal = fitnessGoal
        self.profileImageData = profileImageData
        self.createdAt = createdAt
    }
}
