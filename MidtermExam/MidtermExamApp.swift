import SwiftUI
import SwiftData

@main
struct MidtermExamApp: App {
    @StateObject private var authManager = AuthManager()
    @StateObject private var workoutSessionStore = WorkoutSessionStore()
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(
                for: UserModel.self,
                WorkoutModel.self,
                WorkoutExerciseModel.self,
                WorkoutSetModel.self,
                MealModel.self,
                WeightRecordModel.self
            )
        } catch {
            fatalError("Failed to create model container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(workoutSessionStore)
                .modelContainer(modelContainer)
        }
    }
}
