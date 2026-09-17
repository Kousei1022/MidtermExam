import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            WorkoutView()
                .tabItem {
                    Image(systemName: "figure.strengthtraining.traditional")
                    Text("Workout")
                }
            
            NutritionView()
                .tabItem {
                    Image(systemName: "fork.knife")
                    Text("Nutrition")
                }
            
            ProgressScreen()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Progress")
                }
        }
    }
}

#Preview {
    ContentView()
}
