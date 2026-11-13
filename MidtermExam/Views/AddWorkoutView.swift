import SwiftUI
import SwiftData

struct AddWorkoutView: View {
    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var workoutName = ""
    @State private var workoutType = ""
    @State private var duration = 0
    @State private var sets = 0
    @State private var repetitions = 0
    @State private var date = Date()
    @State private var notes = ""
    @State private var isCompleted = false

    private let types = ["Upper Body", "Lower Body", "Push", "Pull", "Legs", "Cardio", "Full Body"]

    var body: some View {
        ZStack {
            LinearGradient(colors: [FitColors.background, Color(red: 0.05, green: 0.09, blue: 0.16)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Add Workout")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)

                    FitTextField(title: "Workout name", text: $workoutName)

                    Picker("Workout type", selection: $workoutType) {
                        Text("Choose workout").tag("")
                        ForEach(types, id: \ .self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)

                    DatePicker("Training date", selection: $date, displayedComponents: [.date])
                        .tint(FitColors.primary)

                    HStack {
                        Text("Duration")
                            .foregroundStyle(.white)
                        Spacer()
                        Stepper(value: $duration, in: 10...180, step: 5) {
                            Text("\(duration) min")
                                .foregroundStyle(.white)
                        }
                    }

                    HStack {
                        Text("Sets")
                            .foregroundStyle(.white)
                        Spacer()
                        Stepper(value: $sets, in: 1...10) {
                            Text("\(sets)")
                                .foregroundStyle(.white)
                        }
                    }

                    HStack {
                        Text("Repetitions")
                            .foregroundStyle(.white)
                        Spacer()
                        Stepper(value: $repetitions, in: 1...30) {
                            Text("\(repetitions)")
                                .foregroundStyle(.white)
                        }
                    }

                    TextField("Notes", text: $notes, axis: .vertical)
                        .padding(12)
                        .frame(minHeight: 90)
                        .background(Color.white.opacity(0.04))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    Toggle("Workout completed", isOn: $isCompleted)
                        .tint(FitColors.primary)

                    FitButton(title: "Save workout") {
                        saveWorkout()
                    }
                }
                .padding(20)
            }
        }
        .navigationBarBackButtonHidden(false)
    }

    private func saveWorkout() {
        guard let user = authManager.currentUser else { return }
        let selectedType = workoutType.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !selectedType.isEmpty, duration > 0 else { return }

        let workout = WorkoutModel(
            user: user,
            workoutName: workoutName.isEmpty ? selectedType : workoutName,
            workoutType: selectedType,
            date: date,
            duration: duration,
            sets: max(1, sets),
            repetitions: max(1, repetitions),
            notes: notes,
            isCompleted: isCompleted
        )
        context.insert(workout)
        try? context.save()
        dismiss()
    }
}

#Preview {
    AddWorkoutView()
        .environmentObject(AuthManager())
}
