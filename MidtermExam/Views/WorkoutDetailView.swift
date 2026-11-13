import SwiftUI
import SwiftData

struct WorkoutDetailView: View {
    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var workout: WorkoutModel
    @State private var workoutName: String
    @State private var workoutType: String
    @State private var date: Date
    @State private var duration: Int
    @State private var sets: Int
    @State private var repetitions: Int
    @State private var notes: String
    @State private var isCompleted: Bool

    private let types = ["Upper Body", "Lower Body", "Push", "Pull", "Legs", "Cardio", "Full Body"]

    init(workout: WorkoutModel) {
        _workout = State(initialValue: workout)
        _workoutName = State(initialValue: workout.workoutName)
        _workoutType = State(initialValue: workout.workoutType)
        _date = State(initialValue: workout.date)
        _duration = State(initialValue: workout.duration)
        _sets = State(initialValue: workout.sets)
        _repetitions = State(initialValue: workout.repetitions)
        _notes = State(initialValue: workout.notes)
        _isCompleted = State(initialValue: workout.isCompleted)
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [FitColors.background, Color(red: 0.06, green: 0.10, blue: 0.16)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Workout Details")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)

                    FitTextField(title: "Workout name", text: $workoutName)

                    Picker("Workout type", selection: $workoutType) {
                        ForEach(types, id: \ .self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)

                    DatePicker("Workout date", selection: $date, displayedComponents: [.date])
                        .tint(FitColors.primary)

                    HStack {
                        Text("Duration")
                            .foregroundStyle(.white)
                        Spacer()
                        Stepper(value: $duration, in: 10...180) {
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
                        .background(Color(red: 0.96, green: 0.97, blue: 0.99).opacity(0.98))
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    Toggle("Completed", isOn: $isCompleted)
                        .tint(FitColors.primary)

                    HStack(spacing: 12) {
                        FitButton(title: "Save") {
                            saveChanges()
                        }
                        Button("Delete") {
                            context.delete(workout)
                            try? context.save()
                            dismiss()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundStyle(.white)
                        .background(FitColors.danger)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
                .padding(20)
            }
        }
    }

    private func saveChanges() {
        workout.workoutName = workoutName
        workout.workoutType = workoutType
        workout.date = date
        workout.duration = duration
        workout.sets = sets
        workout.repetitions = repetitions
        workout.notes = notes
        workout.isCompleted = isCompleted
        try? context.save()
        dismiss()
    }
}

#Preview {
    WorkoutDetailView(workout: WorkoutModel(user: UserModel(fullName: "Test", username: "test", email: "test@test.com", passwordHash: "hash"), workoutName: "Bench Press", workoutType: "Upper Body", date: Date(), duration: 45, sets: 4, repetitions: 8, notes: "Focus on control", isCompleted: true))
        .environmentObject(AuthManager())
}
