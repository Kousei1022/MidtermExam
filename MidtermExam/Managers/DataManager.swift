import Foundation
import SwiftData

@MainActor
struct DataManager {
    static func workouts(for user: UserModel, context: ModelContext) -> [WorkoutModel] {
        let descriptor = FetchDescriptor<WorkoutModel>()
        return ((try? context.fetch(descriptor)) ?? []).filter { $0.user?.id == user.id }
    }

    static func meals(for user: UserModel, context: ModelContext) -> [MealModel] {
        let descriptor = FetchDescriptor<MealModel>()
        return ((try? context.fetch(descriptor)) ?? []).filter { $0.user?.id == user.id }
    }

    static func weightRecords(for user: UserModel, context: ModelContext) -> [WeightRecordModel] {
        let descriptor = FetchDescriptor<WeightRecordModel>()
        return ((try? context.fetch(descriptor)) ?? []).filter { $0.user?.id == user.id }
    }

    static func totalCalories(for user: UserModel, context: ModelContext) -> Int {
        meals(for: user, context: context).reduce(0) { $0 + $1.calories * $1.servings }
    }

    static func totalProtein(for user: UserModel, context: ModelContext) -> Int {
        meals(for: user, context: context).reduce(0) { $0 + $1.protein * $1.servings }
    }

    static func totalWorkoutMinutes(for user: UserModel, context: ModelContext) -> Int {
        workouts(for: user, context: context).reduce(0) { $0 + $1.duration }
    }

    static func completedWorkouts(for user: UserModel, context: ModelContext) -> [WorkoutModel] {
        workouts(for: user, context: context).filter { $0.isCompleted }
    }

    static func weeklyWorkoutCount(for user: UserModel, context: ModelContext) -> Int {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return workouts(for: user, context: context).filter { $0.date >= weekAgo }.count
    }
}
