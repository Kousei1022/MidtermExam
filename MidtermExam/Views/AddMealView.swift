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
                VStack(alignment: .leading, spacing: 16) {
                    Text("Add Meal")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)

                    FitTextField(title: "Food name", text: $foodName)
                    FitTextField(title: "Calories", text: $calories, keyboardType: .numberPad)
                    FitTextField(title: "Protein (g)", text: $protein, keyboardType: .numberPad)
                    FitTextField(title: "Carbohydrates (g)", text: $carbohydrates, keyboardType: .numberPad)
                    FitTextField(title: "Fat (g)", text: $fat, keyboardType: .numberPad)

                    Picker("Meal category", selection: $mealCategory) {
                        Text("Choose category").tag("")
                        ForEach(categories, id: \ .self) {
                            Text($0).tag($0)
                        }
                    }
                    .pickerStyle(.segmented)

                    DatePicker("Date", selection: $date, displayedComponents: [.date])
                        .tint(FitColors.primary)

                    HStack {
                        Text("Servings")
                            .foregroundStyle(.white)
                        Spacer()
                        Stepper(value: $servings, in: 1...10) {
                            Text("\(servings)")
                                .foregroundStyle(.white)
                        }
                    }

                    FitButton(title: "Save meal") {
                        saveMeal()
                    }
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
