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
    @State private var validationMessage: String?

    private let categories = ["Breakfast", "Lunch", "Dinner", "Snack"]

    var body: some View {
        ZStack {
            LinearGradient(colors: [FitColors.background, FitColors.backgroundSecondary], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("FOOD & NUTRITION")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(FitColors.primary)
                        Text("Add meal")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Save a meal and its nutrition details.")
                            .font(.system(size: 13))
                            .foregroundStyle(FitColors.textSecondary)
                    }
                    .padding(.bottom, 4)

                    FitFormSection(title: "Meal", icon: "fork.knife") {
                        FitTextField(title: "Food name", text: $foodName)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.88))
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
                                HStack(spacing: 10) {
                                    Image(systemName: "tag.fill")
                                        .foregroundStyle(FitColors.primary)
                                    Text(mealCategory.isEmpty ? "Choose category" : mealCategory)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(.white)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(FitColors.textSecondary)
                                }
                                .padding(.horizontal, 14)
                                .frame(maxWidth: .infinity, minHeight: 52)
                                .background(Color.white.opacity(0.04))
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(FitColors.border, lineWidth: 1))
                            }
                        }
                    }

                    FitFormSection(title: "Nutrition", icon: "chart.bar.fill") {
                        FitTextField(title: "Calories (kcal)", text: $calories, keyboardType: .numberPad)
                        FitTextField(title: "Protein (g)", text: $protein, keyboardType: .numberPad)
                        FitTextField(title: "Carbohydrates (g)", text: $carbohydrates, keyboardType: .numberPad)
                        FitTextField(title: "Fat (g)", text: $fat, keyboardType: .numberPad)
                    }

                    FitFormSection(title: "Serving", icon: "calendar") {
                        HStack(spacing: 10) {
                            Image(systemName: "calendar")
                                .foregroundStyle(FitColors.secondary)
                                .frame(width: 20)
                            Text("Meal date")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(FitColors.textSecondary)
                            Spacer(minLength: 4)
                            DatePicker("Meal date", selection: $date, displayedComponents: [.date])
                                .labelsHidden()
                                .tint(FitColors.primary)
                        }
                        FormStepperRow(title: "Servings", value: $servings, range: 1...10)
                    }

                    if let validationMessage {
                        Text(validationMessage)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(FitColors.danger)
                    }

                    FitButton(title: "Save meal") {
                        saveMeal()
                    }
                    .padding(.top, 2)
                }
                .padding(20)
            }
        }
    }

    private func saveMeal() {
        guard let user = authManager.currentUser else {
            validationMessage = "Please sign in before saving a meal."
            return
        }

        let category = mealCategory.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !foodName.isEmpty else {
            validationMessage = "Add a food name before saving."
            return
        }

        guard !category.isEmpty else {
            validationMessage = "Choose a meal category before saving."
            return
        }

        let caloriesValue = Int(calories) ?? 0
        let proteinValue = Int(protein) ?? 0
        let carbsValue = Int(carbohydrates) ?? 0
        let fatValue = Int(fat) ?? 0

        guard caloriesValue > 0 || proteinValue > 0 || carbsValue > 0 || fatValue > 0 else {
            validationMessage = "Enter at least one nutrition value before saving."
            return
        }

        validationMessage = nil

        let meal = MealModel(
            user: user,
            foodName: foodName,
            calories: caloriesValue,
            protein: proteinValue,
            carbohydrates: carbsValue,
            fat: fatValue,
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
