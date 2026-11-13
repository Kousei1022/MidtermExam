
import SwiftUI

struct NutritionView: View {
    @State private var meals: [Meal] = [
        Meal(name: "Grilled Chicken Bowl", calories: 540, protein: 42, servings: 1, isHighProtein: true),
        Meal(name: "Greek Yogurt", calories: 210, protein: 18, servings: 1, isHighProtein: true),
        Meal(name: "Avocado Toast", calories: 320, protein: 12, servings: 1, isHighProtein: false)
    ]

    @State private var foodName = ""
    @State private var caloriesText = ""
    @State private var servings = 1
    @State private var protein = 20
    @State private var isHighProtein = true

    private var totalCalories: Int {
        meals.reduce(0) { $0 + $1.totalCalories }
    }

    private var totalProtein: Int {
        meals.reduce(0) { $0 + $1.totalProtein }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Nutrition dashboard")
                            .font(.title2)
                            .fontWeight(.bold)

                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Calories")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("\(totalCalories)")
                                    .font(.title)
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Protein")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("\(totalProtein)g")
                                    .font(.title)
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Log a meal")
                            .font(.title3)
                            .fontWeight(.semibold)

                        VStack(spacing: 12) {
                            TextField("Food name", text: $foodName)
                                .padding(12)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                            TextField("Calories", text: $caloriesText)
                                .keyboardType(.numberPad)
                                .padding(12)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                            HStack {
                                Text("Servings")
                                    .fontWeight(.medium)
                                Spacer()
                                Stepper(value: $servings, in: 1...10) {
                                    Text("\(servings)")
                                }
                            }
                            .padding(.vertical, 4)

                            HStack {
                                Text("Protein target")
                                    .fontWeight(.medium)
                                Spacer()
                                Stepper(value: $protein, in: 10...100, step: 5) {
                                    Text("\(protein)g")
                                }
                            }
                            .padding(.vertical, 4)

                            Toggle("High protein", isOn: $isHighProtein)
                                .tint(.green)
                        }

                        Button {
                            guard !foodName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                            let calories = Int(caloriesText) ?? 0
                            let newMeal = Meal(
                                name: foodName,
                                calories: calories,
                                protein: protein,
                                servings: servings,
                                isHighProtein: isHighProtein
                            )
                            meals.insert(newMeal, at: 0)
                            foodName = ""
                            caloriesText = ""
                            servings = 1
                            protein = 20
                            isHighProtein = true
                        } label: {
                            Text("Add meal")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(LinearGradient(colors: [.indigo, .blue], startPoint: .leading, endPoint: .trailing))
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Recent meals")
                            .font(.title3)
                            .fontWeight(.semibold)

                        ForEach(meals) { meal in
                            HStack(alignment: .center, spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(meal.isHighProtein ? Color.green.opacity(0.12) : Color.orange.opacity(0.12))
                                        .frame(width: 46, height: 46)

                                    Image(systemName: meal.isHighProtein ? "bolt.fill" : "fork.knife")
                                        .foregroundStyle(meal.isHighProtein ? .green : .orange)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(meal.name)
                                        .font(.headline)
                                    Text("\(meal.totalCalories) kcal • \(meal.totalProtein)g protein")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Text(meal.isHighProtein ? "High protein" : "Balanced")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(meal.isHighProtein ? Color.green.opacity(0.12) : Color.orange.opacity(0.12))
                                    .foregroundStyle(meal.isHighProtein ? .green : .orange)
                                    .clipShape(Capsule())
                            }
                            .padding(12)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Nutrition")
        }
    }
}

#Preview {
    NutritionView()
}
