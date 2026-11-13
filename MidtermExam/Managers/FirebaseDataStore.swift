import Foundation
import FirebaseFirestore
import SwiftData

@MainActor
final class FirebaseDataStore {
    static let shared = FirebaseDataStore()

    private let database = Firestore.firestore()

    private init() {}

    private func userDocument(_ uid: String) -> DocumentReference {
        database.collection("users").document(uid)
    }

    func reserveUsername(_ username: String, uid: String) async throws {
        let reference = database.collection("usernames").document(username.lowercased())
        let snapshot = try await reference.getDocument()
        if snapshot.exists {
            guard snapshot.data()?["uid"] as? String == uid else {
                throw FirebaseDataStoreError.usernameUnavailable
            }
            return
        }
        try await reference.setData(["uid": uid])
    }

    func releaseUsername(_ username: String, uid: String) async throws {
        let reference = database.collection("usernames").document(username.lowercased())
        let snapshot = try await reference.getDocument()
        guard snapshot.data()?["uid"] as? String == uid else { return }
        try await reference.delete()
    }

    func saveProfile(_ user: UserModel, uid: String) async throws {
        try await userDocument(uid).setData(profileData(user, uid: uid), merge: true)
    }

    func loadProfile(uid: String) async throws -> [String: Any]? {
        let snapshot = try await userDocument(uid).getDocument()
        return snapshot.exists ? snapshot.data() : nil
    }

    func saveWorkout(_ workout: WorkoutModel, uid: String) async throws {
        try await userDocument(uid)
            .collection("workouts")
            .document(workout.id.uuidString)
            .setData([
                "id": workout.id.uuidString,
                "workoutName": workout.workoutName,
                "workoutType": workout.workoutType,
                "date": Timestamp(date: workout.date),
                "duration": workout.duration,
                "sets": workout.sets,
                "repetitions": workout.repetitions,
                "notes": workout.notes,
                "isCompleted": workout.isCompleted,
                "updatedAt": Timestamp(date: Date())
            ], merge: true)
    }

    func deleteWorkout(id: UUID, uid: String) async throws {
        try await userDocument(uid).collection("workouts").document(id.uuidString).delete()
    }

    func saveMeal(_ meal: MealModel, uid: String) async throws {
        try await userDocument(uid)
            .collection("meals")
            .document(meal.id.uuidString)
            .setData([
                "id": meal.id.uuidString,
                "foodName": meal.foodName,
                "calories": meal.calories,
                "protein": meal.protein,
                "carbohydrates": meal.carbohydrates,
                "fat": meal.fat,
                "servings": meal.servings,
                "mealCategory": meal.mealCategory,
                "date": Timestamp(date: meal.date),
                "updatedAt": Timestamp(date: Date())
            ], merge: true)
    }

    func deleteMeal(id: UUID, uid: String) async throws {
        try await userDocument(uid).collection("meals").document(id.uuidString).delete()
    }

    func saveWeightRecord(_ record: WeightRecordModel, uid: String) async throws {
        try await userDocument(uid)
            .collection("weights")
            .document(record.id.uuidString)
            .setData([
                "id": record.id.uuidString,
                "weight": record.weight,
                "date": Timestamp(date: record.date)
            ], merge: true)
    }

    func uploadLocalData(for user: UserModel, uid: String, context: ModelContext) async throws {
        try await saveProfile(user, uid: uid)

        let workouts = try context.fetch(FetchDescriptor<WorkoutModel>()).filter { $0.user?.id == user.id }
        for workout in workouts {
            try await saveWorkout(workout, uid: uid)
        }

        let meals = try context.fetch(FetchDescriptor<MealModel>()).filter { $0.user?.id == user.id }
        for meal in meals {
            try await saveMeal(meal, uid: uid)
        }

        let weights = try context.fetch(FetchDescriptor<WeightRecordModel>()).filter { $0.user?.id == user.id }
        for record in weights {
            try await saveWeightRecord(record, uid: uid)
        }
    }

    func syncToLocalCache(for user: UserModel, uid: String, context: ModelContext) async throws {
        if let data = try await loadProfile(uid: uid) {
            applyProfile(data, to: user, uid: uid)
        }

        async let workoutSnapshot = userDocument(uid).collection("workouts").getDocuments()
        async let mealSnapshot = userDocument(uid).collection("meals").getDocuments()
        async let weightSnapshot = userDocument(uid).collection("weights").getDocuments()
        let (remoteWorkouts, remoteMeals, remoteWeights) = try await (workoutSnapshot, mealSnapshot, weightSnapshot)

        let localWorkouts = try context.fetch(FetchDescriptor<WorkoutModel>()).filter { $0.user?.id == user.id }
        let workoutsByID = Dictionary(uniqueKeysWithValues: localWorkouts.map { ($0.id, $0) })
        for document in remoteWorkouts.documents {
            let data = document.data()
            guard let id = UUID(uuidString: document.documentID) else { continue }
            let workout = workoutsByID[id] ?? WorkoutModel(
                id: id,
                user: user,
                workoutName: data["workoutName"] as? String ?? "Workout",
                workoutType: data["workoutType"] as? String ?? "Full Body",
                date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
                duration: data["duration"] as? Int ?? 0,
                sets: data["sets"] as? Int ?? 0,
                repetitions: data["repetitions"] as? Int ?? 0,
                notes: data["notes"] as? String ?? "",
                isCompleted: data["isCompleted"] as? Bool ?? false
            )
            workout.user = user
            workout.workoutName = data["workoutName"] as? String ?? workout.workoutName
            workout.workoutType = data["workoutType"] as? String ?? workout.workoutType
            workout.date = (data["date"] as? Timestamp)?.dateValue() ?? workout.date
            workout.duration = data["duration"] as? Int ?? workout.duration
            workout.sets = data["sets"] as? Int ?? workout.sets
            workout.repetitions = data["repetitions"] as? Int ?? workout.repetitions
            workout.notes = data["notes"] as? String ?? workout.notes
            workout.isCompleted = data["isCompleted"] as? Bool ?? workout.isCompleted
            if workoutsByID[id] == nil { context.insert(workout) }
        }

        let localMeals = try context.fetch(FetchDescriptor<MealModel>()).filter { $0.user?.id == user.id }
        let mealsByID = Dictionary(uniqueKeysWithValues: localMeals.map { ($0.id, $0) })
        for document in remoteMeals.documents {
            let data = document.data()
            guard let id = UUID(uuidString: document.documentID) else { continue }
            let meal = mealsByID[id] ?? MealModel(
                id: id,
                user: user,
                foodName: data["foodName"] as? String ?? "Meal",
                calories: data["calories"] as? Int ?? 0,
                protein: data["protein"] as? Int ?? 0,
                carbohydrates: data["carbohydrates"] as? Int ?? 0,
                fat: data["fat"] as? Int ?? 0,
                servings: data["servings"] as? Int ?? 1,
                mealCategory: data["mealCategory"] as? String ?? "Snack",
                date: (data["date"] as? Timestamp)?.dateValue() ?? Date()
            )
            meal.user = user
            meal.foodName = data["foodName"] as? String ?? meal.foodName
            meal.calories = data["calories"] as? Int ?? meal.calories
            meal.protein = data["protein"] as? Int ?? meal.protein
            meal.carbohydrates = data["carbohydrates"] as? Int ?? meal.carbohydrates
            meal.fat = data["fat"] as? Int ?? meal.fat
            meal.servings = data["servings"] as? Int ?? meal.servings
            meal.mealCategory = data["mealCategory"] as? String ?? meal.mealCategory
            meal.date = (data["date"] as? Timestamp)?.dateValue() ?? meal.date
            if mealsByID[id] == nil { context.insert(meal) }
        }

        let localWeights = try context.fetch(FetchDescriptor<WeightRecordModel>()).filter { $0.user?.id == user.id }
        let weightsByID = Dictionary(uniqueKeysWithValues: localWeights.map { ($0.id, $0) })
        for document in remoteWeights.documents {
            let data = document.data()
            guard let id = UUID(uuidString: document.documentID) else { continue }
            let record = weightsByID[id] ?? WeightRecordModel(
                id: id,
                user: user,
                weight: data["weight"] as? Double ?? 0,
                date: (data["date"] as? Timestamp)?.dateValue() ?? Date()
            )
            record.user = user
            record.weight = data["weight"] as? Double ?? record.weight
            record.date = (data["date"] as? Timestamp)?.dateValue() ?? record.date
            if weightsByID[id] == nil { context.insert(record) }
        }

        try context.save()
    }

    func deleteAccountData(uid: String, username: String) async throws {
        let user = userDocument(uid)
        for collectionName in ["workouts", "meals", "weights"] {
            let snapshot = try await user.collection(collectionName).getDocuments()
            for batchStart in stride(from: 0, to: snapshot.documents.count, by: 450) {
                let batch = database.batch()
                for document in snapshot.documents[batchStart..<min(batchStart + 450, snapshot.documents.count)] {
                    batch.deleteDocument(document.reference)
                }
                try await batch.commit()
            }
        }
        try await user.delete()
        try await releaseUsername(username, uid: uid)
    }

    private func profileData(_ user: UserModel, uid: String) -> [String: Any] {
        [
            "uid": uid,
            "fullName": user.fullName,
            "username": user.username,
            "email": user.email,
            "height": user.height,
            "weight": user.weight,
            "fitnessGoal": user.fitnessGoal,
            "createdAt": Timestamp(date: user.createdAt),
            "updatedAt": Timestamp(date: Date())
        ]
    }

    func applyProfile(_ data: [String: Any], to user: UserModel, uid: String) {
        user.firebaseUID = uid
        user.fullName = data["fullName"] as? String ?? user.fullName
        user.username = data["username"] as? String ?? user.username
        user.email = data["email"] as? String ?? user.email
        user.height = data["height"] as? Double ?? user.height
        user.weight = data["weight"] as? Double ?? user.weight
        user.fitnessGoal = data["fitnessGoal"] as? String ?? user.fitnessGoal
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
