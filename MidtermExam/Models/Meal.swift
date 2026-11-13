import Foundation

struct Meal: Identifiable {
    let id = UUID()
    let name: String
    let calories: Int
    let protein: Int
    let servings: Int
    let isHighProtein: Bool

    var totalCalories: Int {
        calories * servings
    }

    var totalProtein: Int {
        protein * servings
    }
}

