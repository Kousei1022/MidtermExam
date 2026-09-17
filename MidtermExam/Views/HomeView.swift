
import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Welcome Back")
                                .foregroundStyle(.gray)
                            
                            Text("FitTrack")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "figure.run")
                            .font(.system(size: 40))
                    }
                    
                    // Goal Card
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.blue)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("CURRENT GOAL")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.8))
                            
                            Text("Build Strength")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            
                            Text("Keep training consistently!")
                                .foregroundStyle(.white)
                            
                            ProgressView(value: 0.65)
                                .tint(.white)
                        }
                        .padding()
                    }
                    .frame(height: 170)
                    
                    Text("Today's Stats")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    // Stats
                    HStack {
                        StatBox(
                            title: "Workouts",
                            value: "3",
                            icon: "dumbbell.fill"
                        )
                        
                        StatBox(
                            title: "Calories",
                            value: "1,240",
                            icon: "flame.fill"
                        )
                    }
                    
                    HStack {
                        StatBox(
                            title: "Protein",
                            value: "92g",
                            icon: "bolt.fill"
                        )
                        
                        StatBox(
                            title: "Progress",
                            value: "65%",
                            icon: "chart.bar.fill"
                        )
                    }
                    
                    Text("Next Workout")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack {
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.title)
                        
                        VStack(alignment: .leading) {
                            Text("Upper Body")
                                .fontWeight(.bold)
                            
                            Text("Chest • Back • Arms")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                        
                        Spacer()
                        
                        Text("45 min")
                            .fontWeight(.bold)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                .padding()
            }
            .navigationTitle("Home")
        }
    }
}

// Simple Stat Box
struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

#Preview {
    HomeView()
}
