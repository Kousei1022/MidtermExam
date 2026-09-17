import SwiftUI

struct ProgressScreen: View {
    
    @State private var goal = "Build Muscle"
    
    let goals = [
        "Build Muscle",
        "Lose Fat",
        "Maintain Weight",
        "Improve Fitness"
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)
                    
                    Text("Your Progress")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    // Progress Card
                    VStack(spacing: 10) {
                        
                        Text("Weekly Progress")
                            .foregroundStyle(.gray)
                        
                        Text("65%")
                            .font(.system(size: 40))
                            .fontWeight(.bold)
                        
                        // SwiftUI's ProgressView
                        ProgressView(value: 0.65)
                            .tint(.blue)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.15))
                    .clipShape(
                        RoundedRectangle(cornerRadius: 20)
                    )
                    
                    // Statistics
                    HStack {
                        
                        ProgressStat(
                            value: "4",
                            title: "Workouts"
                        )
                        
                        Spacer()
                        
                        ProgressStat(
                            value: "180",
                            title: "Minutes"
                        )
                        
                        Spacer()
                        
                        ProgressStat(
                            value: "5",
                            title: "Day Streak"
                        )
                    }
                    .padding()
                    .background(Color.gray.opacity(0.15))
                    .clipShape(
                        RoundedRectangle(cornerRadius: 20)
                    )
                    
                    // Fitness Goal
                    VStack(alignment: .leading) {
                        
                        Text("Fitness Goal")
                            .font(.headline)
                        
                        Picker(
                            "Goal",
                            selection: $goal
                        ) {
                            ForEach(goals, id: \.self) { goal in
                                Text(goal)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .padding()
                    .background(Color.gray.opacity(0.15))
                    .clipShape(
                        RoundedRectangle(cornerRadius: 20)
                    )
                }
                .padding()
            }
            .navigationTitle("Progress")
        }
    }
}

// Progress Statistic
struct ProgressStat: View {
    
    let value: String
    let title: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.gray)
        }
    }
}

#Preview {
    ProgressScreen()
}
