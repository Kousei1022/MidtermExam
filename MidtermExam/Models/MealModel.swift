import Foundation
import SwiftData

@Model
final class MealModel {
    @Attribute(.unique) var id: UUID
    var user: UserModel?
    var foodName: String
    var calories: Int
    var protein: Int
    var carbohydrates: Int
    var fat: Int
    var servings: Int
    var mealCategory: String
    var date: Date

    init(
        id: UUID = UUID(),
        user: UserModel? = nil,
        foodName: String,
        calories: Int,
        protein: Int,
        carbohydrates: Int,
        fat: Int,
        servings: Int,
        mealCategory: String,
        date: Date
    ) {
        self.id = id
        self.user = user
        self.foodName = foodName
        self.calories = calories
        self.protein = protein
        self.carbohydrates = carbohydrates
        self.fat = fat
        self.servings = servings
        self.mealCategory = mealCategory
        self.date = date
    }
}
