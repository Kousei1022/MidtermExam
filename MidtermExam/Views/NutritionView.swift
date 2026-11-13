
import SwiftUI
import SwiftData

struct NutritionView: View {
    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.modelContext) private var context
    @Query(sort: \MealModel.date, order: .reverse) private var allMeals: [MealModel]
    @State private var selectedPeriod = NutritionPeriod.today
    @State private var mealToDelete: MealModel?
    @State private var showDeleteConfirmation = false

    private var meals: [MealModel] {
        guard let user = authManager.currentUser else { return [] }
        return allMeals.filter { $0.user?.id == user.id }
    }

    private var visibleMeals: [MealModel] {
        switch selectedPeriod {
        case .today:
            return meals.filter { Calendar.current.isDateInToday($0.date) }
        case .week:
            let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            return meals.filter { $0.date >= weekAgo }
        }
    }

    private var totalCalories: Int {
        visibleMeals.reduce(0) { $0 + ($1.calories * $1.servings) }
    }

    private var totalProtein: Int {
        visibleMeals.reduce(0) { $0 + ($1.protein * $1.servings) }
    }

    private var totalCarbohydrates: Int {
        visibleMeals.reduce(0) { $0 + ($1.carbohydrates * $1.servings) }
    }

    private var totalFat: Int {
        visibleMeals.reduce(0) { $0 + ($1.fat * $1.servings) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [FitColors.background, Color(red: 0.04, green: 0.09, blue: 0.14)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("FOOD & NUTRITION")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(FitColors.primary)
                            HStack(alignment: .center) {
                                Text("Meal log")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundStyle(.white)
                                Spacer()
                                NavigationLink(destination: AddMealView()) {
                                    Label("Add meal", systemImage: "plus")
                                        .font(.system(size: 13, weight: .bold))
                                        .padding(.horizontal, 13)
                                        .padding(.vertical, 10)
                                        .foregroundStyle(.black)
                                        .background(FitColors.primary)
                                        .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                                }
                            }
                        }

                        Picker("Meal date range", selection: $selectedPeriod) {
                            ForEach(NutritionPeriod.allCases) { period in
                                Text(period.title).tag(period)
                            }
                        }
                        .pickerStyle(.segmented)
                        .tint(FitColors.primary)

                        FitCard {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(alignment: .center) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("CALORIES")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundStyle(FitColors.textSecondary)
                                        Text("\(totalCalories)")
                                            .font(.system(size: 34, weight: .bold))
                                            .foregroundStyle(.white)
                                        Text("kcal · \(selectedPeriod.subtitle)")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundStyle(FitColors.textSecondary)
                                    }
                                    Spacer()
                                    Image(systemName: "flame.fill")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundStyle(.orange)
                                        .frame(width: 44, height: 44)
                                        .background(Color.orange.opacity(0.13))
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                }

                                Divider().overlay(Color.white.opacity(0.10))

                                HStack(spacing: 0) {
                                    MacroValue(value: "\(totalProtein)g", label: "Protein", color: FitColors.primary)
                                    Spacer()
                                    MacroValue(value: "\(totalCarbohydrates)g", label: "Carbs", color: FitColors.secondary)
                                    Spacer()
                                    MacroValue(value: "\(totalFat)g", label: "Fat", color: .orange)
                                }
                            }
                        }

                        HStack {
                            Text(selectedPeriod == .today ? "Today's meals" : "Last 7 days")
                                .font(.system(size: 19, weight: .bold))
                                .foregroundStyle(.white)
                            Spacer()
                            Text("\(visibleMeals.count) logged")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(FitColors.textSecondary)
                        }

                        if visibleMeals.isEmpty {
                            FitCard {
                                VStack(alignment: .leading, spacing: 8) {
                                    Image(systemName: "fork.knife")
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundStyle(FitColors.primary)
                                    Text("No meals in this period")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(.white)
                                    Text("Logged food and macros will appear here.")
                                        .font(.system(size: 13))
                                        .foregroundStyle(FitColors.textSecondary)
                                }
                            }
                        } else {
                            LazyVStack(spacing: 10) {
                                ForEach(visibleMeals) { meal in
                                    FitCard {
                                        HStack(spacing: 10) {
                                            Image(systemName: "fork.knife")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundStyle(FitColors.primary)
                                                .frame(width: 40, height: 40)
                                                .background(FitColors.primary.opacity(0.12))
                                                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))

                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(meal.foodName)
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundStyle(.white)
                                                    .lineLimit(1)
                                                Text("\(meal.mealCategory) · \(meal.date.formatted(.dateTime.month(.abbreviated).day())) · \(meal.servings) serving\(meal.servings == 1 ? "" : "s")")
                                                    .font(.system(size: 11))
                                                    .foregroundStyle(FitColors.textSecondary)
                                                    .lineLimit(1)
                                            }
                                            Spacer(minLength: 2)
                                            VStack(alignment: .trailing, spacing: 3) {
                                                Text("\(meal.calories * meal.servings) kcal")
                                                    .font(.system(size: 13, weight: .bold))
                                                    .foregroundStyle(.white)
                                                Text("\(meal.protein * meal.servings)g protein")
                                                    .font(.system(size: 10, weight: .medium))
                                                    .foregroundStyle(FitColors.textSecondary)
                                            }
                                            Menu {
                                                Button("Delete meal", systemImage: "trash", role: .destructive) {
                                                    mealToDelete = meal
                                                    showDeleteConfirmation = true
                                                }
                                            } label: {
                                                Image(systemName: "ellipsis")
                                                    .font(.system(size: 15, weight: .bold))
                                                    .foregroundStyle(FitColors.textSecondary)
                                                    .frame(width: 28, height: 36)
                                                    .contentShape(Rectangle())
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .alert("Delete this meal?", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    if let mealToDelete {
                        context.delete(mealToDelete)
                        try? context.save()
                    }
                    mealToDelete = nil
                }
                Button("Cancel", role: .cancel) { mealToDelete = nil }
            } message: {
                Text("This meal will be removed from your log.")
            }
        }
    }

}

private enum NutritionPeriod: String, CaseIterable, Identifiable {
    case today
    case week

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today: "Today"
        case .week: "7 days"
        }
    }

    var subtitle: String {
        switch self {
        case .today: "today"
        case .week: "last 7 days"
        }
    }
}

private struct MacroValue: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(FitColors.textSecondary)
        }
    }
}

#Preview {
    NutritionView()
        .environmentObject(AuthManager())
}
