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
            LinearGradient(colors: [FitColors.background, FitColors.backgroundSecondary], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("TRAINING SESSION")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(FitColors.primary)
                        Text("Add workout")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Record the details of your session.")
                            .font(.system(size: 13))
                            .foregroundStyle(FitColors.textSecondary)
                    }
                    .padding(.bottom, 4)

                    FitFormSection(title: "Session", icon: "dumbbell.fill") {
                        FitTextField(title: "Workout name", text: $workoutName)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Workout type")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.88))
                            WorkoutTypePicker(types: types, selection: $workoutType)
                        }

                        HStack(spacing: 10) {
                            Image(systemName: "calendar")
                                .foregroundStyle(FitColors.secondary)
                                .frame(width: 20)
                            Text("Training date")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(FitColors.textSecondary)
                            Spacer(minLength: 4)
                            DatePicker("Training date", selection: $date, displayedComponents: [.date])
                                .labelsHidden()
                                .tint(FitColors.primary)
                        }
                    }

                    FitFormSection(title: "Performance", icon: "chart.bar.fill") {
                        FormStepperRow(title: "Duration", value: $duration, range: 10...180, step: 5, suffix: "min")
                        Divider().overlay(Color.white.opacity(0.08))
                        FormStepperRow(title: "Sets", value: $sets, range: 1...10)
                        Divider().overlay(Color.white.opacity(0.08))
                        FormStepperRow(title: "Repetitions", value: $repetitions, range: 1...30)
                        Toggle("Workout completed", isOn: $isCompleted)
                            .font(.system(size: 13, weight: .medium))
                            .tint(FitColors.primary)
                            .foregroundStyle(.white.opacity(0.9))
                    }

                    FitFormSection(title: "Notes", icon: "text.alignleft") {
                        TextField("Add notes about this session", text: $notes, axis: .vertical)
                            .padding(12)
                            .frame(minHeight: 86, alignment: .topLeading)
                            .background(Color.white.opacity(0.04))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(FitColors.border, lineWidth: 1)
                            )
                    }

                    FitButton(title: "Save workout") {
                        saveWorkout()
                    }
                    .padding(.top, 2)
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
        if let uid = user.firebaseUID {
            Task {
                try? await FirebaseDataStore.shared.saveWorkout(workout, uid: uid)
            }
        }
        dismiss()
    }
}

#Preview {
    AddWorkoutView()
        .environmentObject(AuthManager())
}
