
import SwiftUI

struct WorkoutView: View {
    
    @State private var workoutType = "Upper Body"
    @State private var duration = 30
    @State private var completed = false
    @State private var showAlert = false
    
    let workoutTypes = [
        "Upper Body",
        "Lower Body",
        "Full Body",
        "Cardio"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                
                Section("Workout Type") {
                    Picker("Choose Workout", selection: $workoutType) {
                        ForEach(workoutTypes, id: \.self) {
                            workout in
                            Text(workout)
                        }
                    }
                }
                
                Section("Duration") {
                    Stepper(
                        "\(duration) minutes",
                        value: $duration,
                        in: 15...120,
                        step: 15
                    )
                }
                
                Section("Workout Status") {
                    Toggle(
                        "Completed",
                        isOn: $completed
                    )
                }
                
                Section {
                    Button("Add Workout") {
                        showAlert = true
                    }
                }
            }
            .navigationTitle("Workout")
            .alert("Workout Added!", isPresented: $showAlert) {
                Button("OK") {
                    
                }
            } message: {
                Text(
                    "\(workoutType) - \(duration) minutes"
                )
            }
        }
    }
}

#Preview {
    WorkoutView()
}
