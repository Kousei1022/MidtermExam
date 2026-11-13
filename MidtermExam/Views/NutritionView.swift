
import SwiftUI
import SwiftData

struct NutritionView: View {
    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.modelContext) private var context

    @State private var meals: [MealModel] = []

    private var totalCalories: Int {
        meals.reduce(0) { $0 + ($1.calories * $1.servings) }
    }

    private var totalProtein: Int {
        meals.reduce(0) { $0 + ($1.protein * $1.servings) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [FitColors.background, Color(red: 0.04, green: 0.09, blue: 0.14)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Nutrition Tracker")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.white)
                        Spacer()
                        NavigationLink(destination: AddMealView()) {
                            Text("Add")
                                .font(.system(size: 14, weight: .bold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .foregroundStyle(.black)
                                .background(FitColors.primary)
                                .clipShape(Capsule())
                        }
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatCard(title: "Calories", value: "\(totalCalories)", subtitle: "This week", icon: "flame.fill", accent: .orange)
                        StatCard(title: "Protein", value: "\(totalProtein)g", subtitle: "Goal", icon: "bolt.fill", accent: .green)
                    }

                    if meals.isEmpty {
                        FitCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("No meals logged yet")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.white)
                                Text("Add your first meal to track calories and protein.")
                                    .font(.system(size: 13))
                                    .foregroundStyle(FitColors.textSecondary)
                            }
                        }
                    } else {
                        List {
                            ForEach(meals.sorted(by: { $0.date > $1.date })) { meal in
                                HStack(alignment: .center, spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(FitColors.primary.opacity(0.15))
                                            .frame(width: 42, height: 42)
                                        Image(systemName: "fork.knife")
                                            .foregroundStyle(FitColors.primary)
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(meal.foodName)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundStyle(.white)
                                        Text("\(meal.calories * meal.servings) kcal • \(meal.protein * meal.servings)g protein")
                                            .font(.system(size: 12))
                                            .foregroundStyle(FitColors.textSecondary)
                                    }

                                    Spacer()

                                    Text(meal.mealCategory)
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundStyle(FitColors.primary)
                                }
                                .padding(.vertical, 6)
                                .listRowBackground(Color.clear)
                            }
                            .onDelete { indexSet in
                                guard let index = indexSet.first else { return }
                                let item = meals[index]
                                context.delete(item)
                                try? context.save()
                                loadMeals()
                            }
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
                .padding(20)
            }
            .onAppear { loadMeals() }
        }
    }

    private func loadMeals() {
        guard let user = authManager.currentUser else { return }
        meals = DataManager.meals(for: user, context: context)
    }
}

#Preview {
    NutritionView()
        .environmentObject(AuthManager())
}
