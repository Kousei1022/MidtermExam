import SwiftUI

struct MainTabView: View {
    let currentUser: UserModel

    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tag(0)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            WorkoutView()
                .tag(1)
                .tabItem {
                    Label("Workout", systemImage: "figure.strengthtraining.traditional")
                }

            NutritionView()
                .tag(2)
                .tabItem {
                    Label("Nutrition", systemImage: "fork.knife")
                }

            ProgressDashboardView()
                .tag(3)
                .tabItem {
                    Label("Progress", systemImage: "chart.bar.fill")
                }
        }
        .tint(FitColors.primary)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    MainTabView(currentUser: UserModel(fullName: "Test User", username: "test", email: "test@test.com", passwordHash: "hash"))
}
