
import SwiftUI

struct NutritionView: View {
    
    @State private var foodName = ""
    @State private var calories = ""
    @State private var servings = 1
    @State private var highProtein = false
    @State private var showMeal = false
    
    var body: some View {
        NavigationStack {
            Form {
                
                Section("Meal Information") {
                    
                    TextField(
                        "Food Name",
                        text: $foodName
                    )
                    
                    TextField(
                        "Calories",
                        text: $calories
                    )
                    .keyboardType(.numberPad)
                }
                
                Section("Servings") {
                    Stepper(
                        "\(servings) serving(s)",
                        value: $servings,
                        in: 1...10
                    )
                }
                
                Section {
                    Toggle(
                        "High Protein",
                        isOn: $highProtein
                    )
                }
                
                Section {
                    Button("Add Meal") {
                        showMeal = true
                    }
                }
                
                if showMeal {
                    Section("Meal Added") {
                        Text(
                            foodName.isEmpty
                            ? "Unnamed Meal"
                            : foodName
                        )
                        
                        Text(
                            "\(calories.isEmpty ? "0" : calories) calories"
                        )
                        
                        Text("Servings: \(servings)")
                        
                        if highProtein {
                            Text("High Protein ✓")
                                .foregroundStyle(.green)
                        }
                    }
                }
            }
            .navigationTitle("Nutrition")
        }
    }
}

#Preview {
    NutritionView()
}
