import Foundation
import SwiftData

@MainActor
final class FirebaseDataStore {
    static let shared = FirebaseDataStore()

    private init() {}

    func reserveUsername(_ username: String, uid: String) async throws {}

    func releaseUsername(_ username: String, uid: String) async throws {}

    func saveProfile(_ user: UserModel, uid: String) async throws {}

    func loadProfile(uid: String) async throws -> [String: Any]? { nil }

    func saveWorkout(_ workout: WorkoutModel, uid: String) async throws {}

    func deleteWorkout(id: UUID, uid: String) async throws {}

    func saveMeal(_ meal: MealModel, uid: String) async throws {}

    func deleteMeal(id: UUID, uid: String) async throws {}

    func saveWeightRecord(_ record: WeightRecordModel, uid: String) async throws {}

    func uploadLocalData(for user: UserModel, uid: String, context: ModelContext) async throws {}

    func syncToLocalCache(for user: UserModel, uid: String, context: ModelContext) async throws {}

    func deleteAccountData(uid: String, username: String) async throws {}

    func applyProfile(_ data: [String: Any], to user: UserModel, uid: String) {
        user.firebaseUID = uid
    }
}

enum FirebaseDataStoreError: LocalizedError {
    case usernameUnavailable

    var errorDescription: String? {
        switch self {
        case .usernameUnavailable:
            "That username is already in use."
        }
    }
}
