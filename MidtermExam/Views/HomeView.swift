
import SwiftUI
import SwiftData

struct HomeView: View {
    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.modelContext) private var context

    @State private var workouts: [WorkoutModel] = []
    @State private var meals: [MealModel] = []

    private var user: UserModel? {
        authManager.currentUser
    }

    private var totalCalories: Int {
        meals.reduce(0) { $0 + ($1.calories * $1.servings) }
    }

    private var totalProtein: Int {
        meals.reduce(0) { $0 + ($1.protein * $1.servings) }
    }

    private var currentGoalProgress: Double {
        guard let user else { return 0 }
        let minutes = DataManager.totalWorkoutMinutes(for: user, context: context)
        return min(1, Double(minutes) / 240.0)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [FitColors.background, Color(red: 0.05, green: 0.09, blue: 0.15)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Welcome back")
                                    .font(.system(size: 13))
                                    .foregroundStyle(FitColors.textSecondary)
                                Text(user?.fullName ?? "User")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                            Spacer()
                            Circle()
                                .fill(FitColors.primary)
                                .frame(width: 46, height: 46)
                                .overlay(Text(String((user?.fullName.prefix(1) ?? "U")).uppercased()).font(.system(size: 18, weight: .heavy)).foregroundStyle(.black))
                        }

                        FitCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Current Goal")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(FitColors.textSecondary)
                                Text(user?.fitnessGoal ?? "Build Muscle")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(.white)
                                ProgressView(value: currentGoalProgress)
                                    .tint(FitColors.primary)
                                    .scaleEffect(y: 1.4)
                                Text("\(Int(currentGoalProgress * 100))% complete")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(FitColors.primary)
                            }
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Today's stats")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.white)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                StatCard(title: "Workouts", value: "\(workouts.count)", subtitle: "This week", icon: "dumbbell.fill", accent: FitColors.primary)
                                StatCard(title: "Calories", value: "\(totalCalories)", subtitle: "Logged", icon: "flame.fill", accent: .orange)
                                StatCard(title: "Protein", value: "\(totalProtein)g", subtitle: "Target", icon: "bolt.fill", accent: .green)
                                StatCard(title: "Progress", value: "\(Int(currentGoalProgress * 100))%", subtitle: "Goal", icon: "chart.bar.fill", accent: FitColors.secondary)
                            }
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Quick actions")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.white)

                            HStack(spacing: 12) {
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

                        if let user, !workouts.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Next workout")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(.white)

                                let nextWorkout = workouts.sorted(by: { $0.date < $1.date }).first
                                if let nextWorkout {
                                    HStack {
                                        Image(systemName: "figure.strengthtraining.traditional")
                                            .foregroundStyle(FitColors.primary)
                                        VStack(alignment: .leading) {
                                            Text(nextWorkout.workoutName)
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundStyle(.white)
                                            Text("\(nextWorkout.workoutType) • \(nextWorkout.duration) min")
                                                .font(.system(size: 12))
                                                .foregroundStyle(FitColors.textSecondary)
                                        }
                                        Spacer()
                                        Text(nextWorkout.isCompleted ? "Done" : "Planned")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundStyle(nextWorkout.isCompleted ? .green : FitColors.primary)
                                    }
                                    .padding(14)
                                    .background(Color.white.opacity(0.04))
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                }
                            }
                        }

                        NavigationLink(destination: ProfileView()) {
                            HStack {
                                Text("Profile & settings")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(FitColors.textSecondary)
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.04))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                    }
                    .padding(20)
                }
            }
            .onAppear {
                guard let user else { return }
                workouts = DataManager.workouts(for: user, context: context)
                meals = DataManager.meals(for: user, context: context)
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
                .font(.system(size: 18, weight: .bold))
            Text(label)
                .font(.system(size: 12, weight: .semibold))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.04))
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthManager())
}
