import SwiftUI
import SwiftData

struct ProgressDashboardView: View {
    @EnvironmentObject private var authManager: AuthManager
    @Query(sort: \WorkoutModel.date, order: .reverse) private var allWorkouts: [WorkoutModel]
    @Query(sort: \MealModel.date, order: .reverse) private var allMeals: [MealModel]
    @Query(sort: \WeightRecordModel.date, order: .reverse) private var allWeightRecords: [WeightRecordModel]

    private var user: UserModel? {
        authManager.currentUser
    }

    private var workouts: [WorkoutModel] {
        guard let user else { return [] }
        return allWorkouts.filter { $0.user?.id == user.id }
    }

    private var meals: [MealModel] {
        guard let user else { return [] }
        return allMeals.filter { $0.user?.id == user.id }
    }

    private var recentMeals: [MealModel] {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return meals.filter { $0.date >= weekAgo }
    }

    private var latestWeight: WeightRecordModel? {
        guard let user else { return nil }
        return allWeightRecords.first { $0.user?.id == user.id }
    }

    private var totalWorkoutMinutes: Int {
        workouts.reduce(0) { $0 + $1.duration }
    }

    private var weeklyCount: Int {
        thisWeeksWorkouts.count
    }

    private var thisWeeksWorkouts: [WorkoutModel] {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return workouts.filter { $0.date >= weekAgo }
    }

    private var weeklyMinutes: Int {
        thisWeeksWorkouts.reduce(0) { $0 + $1.duration }
    }

    private var completedCount: Int {
        workouts.filter(\.isCompleted).count
    }

    private var dailyMinutes: [Int] {
        (0..<7).map { offset in
            guard let date = Calendar.current.date(byAdding: .day, value: offset - 6, to: Date()) else { return 0 }
            return workouts.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
                .reduce(0) { $0 + $1.duration }
        }
    }

    private var dailyLabels: [String] {
        (0..<7).map { offset in
            guard let date = Calendar.current.date(byAdding: .day, value: offset - 6, to: Date()) else { return "" }
            return date.formatted(.dateTime.weekday(.narrow))
        }
    }

    private var totalCalories: Int {
        recentMeals.reduce(0) { $0 + ($1.calories * $1.servings) }
    }

    private var totalProtein: Int {
        recentMeals.reduce(0) { $0 + ($1.protein * $1.servings) }
    }

    private var progressPercent: Int {
        min(100, Int(Double(weeklyMinutes) / 240.0 * 100.0))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [FitColors.background, FitColors.backgroundSecondary], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("YOUR TRAINING")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(FitColors.primary)
                            Text("Progress")
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }

                        FitCard {
                            VStack(alignment: .center, spacing: 14) {
                                ZStack {
                                    Circle()
                                        .stroke(Color.white.opacity(0.10), lineWidth: 12)
                                        .frame(width: 124, height: 124)
                                    Circle()
                                        .trim(from: 0, to: Double(progressPercent) / 100.0)
                                        .stroke(FitColors.primary, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                                        .rotationEffect(.degrees(-90))
                                        .frame(width: 124, height: 124)
                                    Text("\(progressPercent)%")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                                Text("Weekly training goal")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.white)
                                Text("\(weeklyMinutes) of 240 minutes")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(FitColors.textSecondary)
                                ProgressView(value: Double(progressPercent), total: 100)
                                    .tint(FitColors.primary)
                                    .padding(.horizontal, 12)
                            }
                            .frame(maxWidth: .infinity)
                        }

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            StatCard(title: "Workouts", value: "\(weeklyCount)", subtitle: "Last 7 days", icon: "dumbbell.fill", accent: FitColors.primary)
                            StatCard(title: "Training time", value: "\(weeklyMinutes)", subtitle: "Minutes · last 7 days", icon: "timer", accent: FitColors.secondary)
                            StatCard(title: "Completed", value: "\(completedCount)", subtitle: "All time", icon: "checkmark.circle.fill", accent: FitColors.success)
                            StatCard(title: "Total time", value: "\(totalWorkoutMinutes / 60)h", subtitle: "All time", icon: "clock.fill", accent: .orange)
                        }

                        FitCard {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Training activity")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundStyle(.white)
                                        Text("Minutes per day · last 7 days")
                                            .font(.system(size: 12))
                                            .foregroundStyle(FitColors.textSecondary)
                                    }
                                    Spacer()
                                    Text("\(dailyMinutes.reduce(0, +)) min")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(FitColors.primary)
                                }

                                HStack(alignment: .bottom, spacing: 0) {
                                    ForEach(dailyMinutes.indices, id: \.self) { index in
                                        VStack(spacing: 8) {
                                            GeometryReader { geometry in
                                                VStack {
                                                    Spacer(minLength: 0)
                                                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                                                        .fill(dailyMinutes[index] > 0 ? FitColors.primary : FitColors.panelAlt)
                                                        .frame(height: max(4, geometry.size.height * CGFloat(dailyMinutes[index]) / CGFloat(max(dailyMinutes.max() ?? 1, 1))))
                                                }
                                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            }
                                            .frame(height: 76)

                                            Text(dailyLabels[index])
                                                .font(.system(size: 11, weight: .medium))
                                                .foregroundStyle(FitColors.textSecondary)
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                }
                            }
                        }

                        FitCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Fitness goal")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.white)
                                Text(user?.fitnessGoal ?? "Set your goal in Profile")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(FitColors.primary)
                                Text("Your goal is saved in your profile and updates when you edit it.")
                                    .font(.system(size: 12))
                                    .foregroundStyle(FitColors.textSecondary)
                            }
                        }

                        FitCard {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    Text("Nutrition · last 7 days")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(.white)
                                    Spacer()
                                    NavigationLink(destination: NutritionView()) {
                                        Text("Open log")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundStyle(FitColors.primary)
                                    }
                                }
                                HStack(spacing: 0) {
                                    ProgressNutritionValue(label: "Calories", value: "\(totalCalories)", color: .orange)
                                    Spacer()
                                    ProgressNutritionValue(label: "Protein", value: "\(totalProtein)g", color: FitColors.primary)
                                }
                            }
                        }

                        if let latestWeight {
                            FitCard {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Latest weigh-in")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(.white)
                                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                                        Text(latestWeight.weight.formatted())
                                            .font(.system(size: 28, weight: .bold))
                                            .foregroundStyle(.white)
                                        Text("kg · \(latestWeight.date.formatted(.dateTime.month(.abbreviated).day()))")
                                            .font(.system(size: 12))
                                            .foregroundStyle(FitColors.textSecondary)
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
        }
    }
}

private struct ProgressNutritionValue: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(FitColors.textSecondary)
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(color)
        }
    }
}

#Preview {
    ProgressDashboardView()
        .environmentObject(AuthManager())
}
