
import SwiftUI
import SwiftData

struct HomeView: View {
    @EnvironmentObject private var authManager: AuthManager
    @Query(sort: \WorkoutModel.date, order: .reverse) private var allWorkouts: [WorkoutModel]
    @Query(sort: \MealModel.date, order: .reverse) private var allMeals: [MealModel]

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

    private var thisWeeksWorkouts: [WorkoutModel] {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return workouts.filter { $0.date >= weekAgo }
    }

    private var todaysMeals: [MealModel] {
        meals.filter { Calendar.current.isDateInToday($0.date) }
    }

    private var totalCalories: Int {
        todaysMeals.reduce(0) { $0 + ($1.calories * $1.servings) }
    }

    private var totalProtein: Int {
        todaysMeals.reduce(0) { $0 + ($1.protein * $1.servings) }
    }

    private var weeklyMinutes: Int {
        thisWeeksWorkouts.reduce(0) { $0 + $1.duration }
    }

    private var currentGoalProgress: Double {
        min(1, Double(weeklyMinutes) / 240.0)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [FitColors.background, Color(red: 0.05, green: 0.09, blue: 0.15)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        header
                        weeklyGoalCard
                        weeklyStats
                        quickActions
                        recentWorkouts
                    }
                    .padding(20)
                }
            }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day()).uppercased())
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(FitColors.textSecondary)
                Text(user?.fullName ?? "User")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.white)
            }
            Spacer()
            NavigationLink(destination: ProfileView()) {
                Circle()
                    .fill(FitColors.primary)
                    .frame(width: 48, height: 48)
                    .overlay {
                        Text(String((user?.fullName.prefix(1) ?? "U")).uppercased())
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.black)
                    }
                    .overlay(Circle().stroke(Color.white.opacity(0.35), lineWidth: 1))
            }
        }
    }

    private var weeklyGoalCard: some View {
        FitCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("WEEKLY TRAINING GOAL")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(FitColors.primary)
                        Text(user?.fitnessGoal ?? "Build Muscle")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    Image(systemName: "figure.run")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(FitColors.primary)
                        .frame(width: 42, height: 42)
                        .background(FitColors.primary.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                ProgressView(value: currentGoalProgress)
                    .tint(FitColors.primary)
                HStack {
                    Text("\(weeklyMinutes) of 240 min")
                    Spacer()
                    Text("\(Int(currentGoalProgress * 100))%")
                        .fontWeight(.bold)
                        .foregroundStyle(FitColors.primary)
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(FitColors.textSecondary)
            }
        }
    }

    private var weeklyStats: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your week")
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(.white)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatCard(title: "Workouts", value: "\(thisWeeksWorkouts.count)", subtitle: "Last 7 days", icon: "dumbbell.fill", accent: FitColors.primary)
                StatCard(title: "Training", value: "\(weeklyMinutes)", subtitle: "Minutes · last 7 days", icon: "clock.fill", accent: FitColors.secondary)
                StatCard(title: "Calories", value: "\(totalCalories)", subtitle: "Logged today", icon: "flame.fill", accent: .orange)
                StatCard(title: "Protein", value: "\(totalProtein)g", subtitle: "Logged today", icon: "bolt.fill", accent: .green)
            }
        }
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick access")
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(.white)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                NavigationLink(destination: WorkoutView()) {
                    QuickActionButton(label: "Workout", icon: "figure.strengthtraining.traditional")
                }
                NavigationLink(destination: NutritionView()) {
                    QuickActionButton(label: "Nutrition", icon: "fork.knife")
                }
                NavigationLink(destination: ProgressDashboardView()) {
                    QuickActionButton(label: "Progress", icon: "chart.bar.fill")
                }
            }
        }
    }

    private var recentWorkouts: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent workouts")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
                NavigationLink("See all", destination: WorkoutView())
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(FitColors.primary)
            }

            if workouts.isEmpty {
                FitCard {
                    HStack(spacing: 12) {
                        Image(systemName: "figure.strengthtraining.traditional")
                            .foregroundStyle(FitColors.primary)
                            .frame(width: 38, height: 38)
                            .background(FitColors.primary.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Ready for your first session?")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white)
                            Text("Your workout log will appear here.")
                                .font(.system(size: 12))
                                .foregroundStyle(FitColors.textSecondary)
                        }
                        Spacer(minLength: 0)
                    }
                }
            } else {
                FitCard {
                    VStack(spacing: 0) {
                        ForEach(workouts.prefix(3)) { workout in
                            NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                                HStack(spacing: 12) {
                                    Image(systemName: workout.isCompleted ? "checkmark.circle.fill" : "figure.strengthtraining.traditional")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundStyle(workout.isCompleted ? FitColors.success : FitColors.primary)
                                        .frame(width: 38, height: 38)
                                        .background(FitColors.panelAlt)
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(workout.workoutName)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundStyle(.white)
                                            .lineLimit(1)
                                        Text("\(workout.workoutType) · \(workout.duration) min")
                                            .font(.system(size: 12))
                                            .foregroundStyle(FitColors.textSecondary)
                                    }
                                    Spacer(minLength: 4)
                                    Text(workout.date.formatted(.dateTime.month(.abbreviated).day()))
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundStyle(FitColors.textSecondary)
                                }
                                .padding(.vertical, 9)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            if workout.id != workouts.prefix(3).last?.id {
                                Divider().overlay(Color.white.opacity(0.08))
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct QuickActionButton: View {
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .semibold))
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, minHeight: 76)
        .background(FitColors.panel)
        .foregroundStyle(FitColors.text)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(FitColors.border, lineWidth: 1))
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthManager())
}
