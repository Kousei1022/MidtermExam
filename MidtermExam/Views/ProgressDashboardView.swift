import SwiftUI
import SwiftData

struct ProgressDashboardView: View {
    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.modelContext) private var context

    private var user: UserModel? {
        authManager.currentUser
    }

    private var workouts: [WorkoutModel] {
        user == nil ? [] : DataManager.workouts(for: user!, context: context)
    }

    private var meals: [MealModel] {
        user == nil ? [] : DataManager.meals(for: user!, context: context)
    }

    private var totalWorkoutMinutes: Int {
        workouts.reduce(0) { $0 + $1.duration }
    }

    private var weeklyCount: Int {
        workouts.filter { $0.date >= Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date() }.count
    }

    private var totalCalories: Int {
        meals.reduce(0) { $0 + ($1.calories * $1.servings) }
    }

    private var totalProtein: Int {
        meals.reduce(0) { $0 + ($1.protein * $1.servings) }
    }

    private var progressPercent: Int {
        guard let user else { return 0 }
        let total = max(1, DataManager.totalWorkoutMinutes(for: user, context: context))
        let percent = min(100, Int(Double(total) / 240.0 * 100.0))
        return percent
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [FitColors.background, Color(red: 0.05, green: 0.09, blue: 0.15)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Progress")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.white)

                        FitCard {
                            VStack(alignment: .center, spacing: 10) {
                                ZStack {
                                    Circle()
                                        .stroke(Color.white.opacity(0.12), lineWidth: 12)
                                        .frame(width: 110, height: 110)
                                    Circle()
                                        .trim(from: 0, to: Double(progressPercent) / 100.0)
                                        .stroke(FitColors.primary, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                                        .rotationEffect(.degrees(-90))
                                        .frame(width: 110, height: 110)
                                    Text("\(progressPercent)%")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                                Text("Overall progress")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(FitColors.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                        }

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            StatCard(title: "Workouts", value: "\(workouts.count)", subtitle: "Total", icon: "dumbbell.fill", accent: FitColors.primary)
                            StatCard(title: "Minutes", value: "\(totalWorkoutMinutes)", subtitle: "Training", icon: "timer", accent: FitColors.secondary)
                            StatCard(title: "Streak", value: "\(weeklyCount)d", subtitle: "This week", icon: "flame.fill", accent: .orange)
                        }

                        FitCard {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Fitness goal")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.white)
                                Text(user?.fitnessGoal ?? "Build Muscle")
                                    .font(.system(size: 16))
                                    .foregroundStyle(FitColors.primary)
                            }
                        }

                        FitCard {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Nutrition totals")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.white)
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Calories")
                                            .foregroundStyle(FitColors.textSecondary)
                                        Text("\(totalCalories)")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundStyle(.white)
                                    }
                                    Spacer()
                                    VStack(alignment: .leading) {
                                        Text("Protein")
                                            .foregroundStyle(FitColors.textSecondary)
                                        Text("\(totalProtein)g")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundStyle(.white)
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

#Preview {
    ProgressDashboardView()
        .environmentObject(AuthManager())
}
