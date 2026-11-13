import SwiftUI
import SwiftData

struct AddMealView: View {
    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var foodName = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbohydrates = ""
    @State private var fat = ""
    @State private var servings = 1
    @State private var mealCategory = ""
    @State private var date = Date()

    private let categories = ["Breakfast", "Lunch", "Dinner", "Snack"]

    var body: some View {
        ZStack {
            LinearGradient(colors: [FitColors.background, Color(red: 0.04, green: 0.08, blue: 0.14)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Add Meal")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)

                    VStack(alignment: .leading, spacing: 16) {
                        Text("FOOD DETAILS")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(FitColors.primary)

                        FitTextField(title: "Food name", text: $foodName)

                        VStack(alignment: .leading, spacing: 9) {
                            Text("Meal category")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.85))

                            Menu {
                                ForEach(categories, id: \.self) { category in
                                    Button {
                                        mealCategory = category
                                    } label: {
                                        if mealCategory == category {
                                            Label(category, systemImage: "checkmark")
                                        } else {
                                            Text(category)
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "fork.knife")
                                        .foregroundStyle(FitColors.background)
                                    Text(mealCategory.isEmpty ? "Choose category" : mealCategory)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(.black)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(.black.opacity(0.65))
                                }
                                .padding(.horizontal, 14)
                                .frame(maxWidth: .infinity, minHeight: 48)
                                .background(Color(red: 0.96, green: 0.97, blue: 0.99))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("NUTRITION FACTS")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(FitColors.primary)

                            FitTextField(title: "Calories", text: $calories, keyboardType: .numberPad)

                            HStack(spacing: 10) {
                                FitTextField(title: "Protein (g)", text: $protein, keyboardType: .numberPad)
                                FitTextField(title: "Carbs (g)", text: $carbohydrates, keyboardType: .numberPad)
                            }
                            FitTextField(title: "Fat (g)", text: $fat, keyboardType: .numberPad)
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("MEAL DETAILS")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(FitColors.primary)

                            DatePicker("Date", selection: $date, displayedComponents: [.date])
                                .tint(FitColors.primary)
                                .foregroundStyle(.white)

                            HStack {
                                Text("Servings")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.9))
                                Spacer()
                                Stepper(value: $servings, in: 1...10) {
                                    Text("\(servings)")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(.white)
                                }
                            }
                        }

                        FitButton(title: "Save meal") {
                            saveMeal()
                        }
                    }
                    .padding(18)
                    .background(Color(red: 0.18, green: 0.22, blue: 0.28).opacity(0.92))
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
                }
                .padding(20)
            }
        }
    }

    private func saveMeal() {
        guard let user = authManager.currentUser else { return }
        let category = mealCategory.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !foodName.isEmpty, !category.isEmpty else { return }

        let meal = MealModel(
            user: user,
            foodName: foodName,
            calories: Int(calories) ?? 0,
            protein: Int(protein) ?? 0,
            carbohydrates: Int(carbohydrates) ?? 0,
            fat: Int(fat) ?? 0,
            servings: max(1, servings),
            mealCategory: category,
            date: date
        )
        context.insert(meal)
        try? context.save()
        dismiss()
    }
}

#Preview {
    AddMealView()
        .environmentObject(AuthManager())
}
