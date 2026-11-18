import SwiftUI
import SwiftData

@main
struct MidtermExamApp: App {
    @StateObject private var authManager = AuthManager()
    @StateObject private var workoutSessionStore = WorkoutSessionStore()
    let modelContainer: ModelContainer

    init() {
        let schema = Schema([
            UserModel.self,
            WorkoutModel.self,
            WorkoutExerciseModel.self,
            WorkoutSetModel.self,
            MealModel.self,
            WeightRecordModel.self
        ])

        do {
            modelContainer = try ModelContainer(for: schema)
        } catch {
            print("SwiftData persistent container could not be opened: \(error)")
            do {
                let recoveryConfiguration = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: true
                )
                modelContainer = try ModelContainer(
                    for: schema,
                    configurations: recoveryConfiguration
                )
            } catch {
                fatalError("SwiftData could not create a recovery container: \(error)")
            }
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
