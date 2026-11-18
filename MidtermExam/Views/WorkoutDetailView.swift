import SwiftUI
import SwiftData
import Combine

struct WorkoutDetailView: View {
    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var workout: WorkoutModel
    @State private var sessionName: String
    @State private var workoutDate: Date
    @State private var exercises: [ExerciseDraft]
    @State private var isCompleted: Bool
    @State private var validationMessage: String?
    @State private var timerSeconds = 0
    @State private var timerRunning = false
    @State private var restSeconds = 0
    @State private var restTimerRunning = false

    init(workout: WorkoutModel) {
        _workout = State(initialValue: workout)
        _sessionName = State(initialValue: workout.sessionTitle.isEmpty ? workout.workoutName : workout.sessionTitle)
        _workoutDate = State(initialValue: workout.date)
        _exercises = State(initialValue: workout.exercises.map { exercise in
            var draft = ExerciseDraft()
            draft.name = exercise.exerciseName
            draft.muscleGroup = exercise.muscleGroup
            draft.notes = exercise.notes
            draft.duration = exercise.duration
            draft.weight = String(exercise.distance)
            draft.sets = exercise.sets.enumerated().map { index, set in
                var setDraft = SetDraft()
                setDraft.weight = String(set.weight)
                setDraft.repetitions = set.repetitions
                setDraft.duration = set.duration
                setDraft.distance = String(set.distance)
                setDraft.notes = set.notes
                setDraft.isCompleted = set.isCompleted ?? false
                return setDraft
            }
            if draft.sets.isEmpty {
                draft.sets = [SetDraft()]
            }
            return draft
        })
        _isCompleted = State(initialValue: workout.isCompleted)
        _timerSeconds = State(initialValue: workout.duration * 60)
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [FitColors.background, Color(red: 0.06, green: 0.10, blue: 0.16)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("WORKOUT DETAILS")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(FitColors.primary)
                        Text("Edit session")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(.white)
                    }

                    FitFormSection(title: "Session", icon: "dumbbell.fill") {
                        FitTextField(title: "Workout title", text: $sessionName)
                        HStack(spacing: 10) {
                            Image(systemName: "calendar")
                                .foregroundStyle(FitColors.secondary)
                                .frame(width: 20)
                            Text("Workout date")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(FitColors.textSecondary)
                            Spacer(minLength: 4)
                            DatePicker("Workout date", selection: $workoutDate, displayedComponents: [.date])
                                .labelsHidden()
                                .tint(FitColors.primary)
                        }
                    }

                    FitCard {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Session timer")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.white)
                                Spacer()
                                Button(timerRunning ? "Pause" : "Start") {
                                    timerRunning.toggle()
                                }
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(FitColors.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                            Text(formatDuration(timerSeconds))
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundStyle(FitColors.primary)
                                .monospacedDigit()
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Exercises")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Spacer()
                            Button {
                                exercises.append(ExerciseDraft())
                            } label: {
                                Label("Add exercise", systemImage: "plus")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.black)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(FitColors.primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                        }

                        ForEach(Array(exercises.enumerated()), id: \.offset) { index, exercise in
                            ExerciseEditorCard(
                                exerciseIndex: index,
                                exercise: Binding(
                                    get: { exercise },
                                    set: { exercises[index] = $0 }
                                ),
                                onRemove: { exercises.remove(at: index) },
                                onAddSet: { exercises[index].sets.append(SetDraft()) },
                                onRemoveSet: { setIndex in
                                    if exercises[index].sets.count > 1 {
                                        exercises[index].sets.remove(at: setIndex)
                                    }
                                },
                                library: [],
                                selectedCategory: Binding(
                                    get: { "All" },
                                    set: { _ in }
                                ),
                                searchText: Binding(
                                    get: { "" },
                                    set: { _ in }
                                ),
                                onSelectLibraryItem: { _ in }
                            )
                        }
                    }

                    Toggle("Completed", isOn: $isCompleted)
                        .tint(FitColors.primary)
                        .foregroundStyle(.white)

                    if let validationMessage {
                        Text(validationMessage)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(FitColors.danger)
                    }

                    HStack(spacing: 12) {
                        FitButton(title: "Save changes") {
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
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if timerRunning {
                if timerSeconds > 0 {
                    timerSeconds -= 1
                } else {
                    timerRunning = false
                }
            }
            if restTimerRunning {
                if restSeconds > 0 {
                    restSeconds -= 1
                } else {
                    restTimerRunning = false
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            FitBackButton(dismiss: dismiss)
        }
    }

    private func saveChanges() {
        let filteredExercises = exercises.filter { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        guard !filteredExercises.isEmpty else {
            validationMessage = "Add at least one exercise before saving."
            return
        }

        workout.sessionTitle = sessionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Workout Session" : sessionName
        workout.workoutName = workout.sessionTitle
        workout.date = workoutDate
        workout.isCompleted = isCompleted
        workout.duration = max(timerSeconds / 60, filteredExercises.reduce(0) { $0 + $1.duration })

        if isCompleted {
            workout.endDate = Date()
        }
        workout.refreshDerivedSummary()
        workout.sets = workout.totalSetsCount
        workout.repetitions = workout.totalRepsCount
        workout.workoutType = filteredExercises.first?.muscleGroup ?? "Training"

        for oldExercise in workout.exercises {
            for oldSet in oldExercise.sets {
                context.delete(oldSet)
            }
            context.delete(oldExercise)
        }
        workout.exercises.removeAll()
        var rebuilt: [WorkoutExerciseModel] = []

        for (index, draft) in filteredExercises.enumerated() {
            let exercise = WorkoutExerciseModel(
                workout: workout,
                exerciseName: draft.name,
                muscleGroup: draft.muscleGroup,
                notes: draft.notes,
                duration: draft.duration,
                distance: Double(draft.weight) ?? 0,
                orderIndex: index,
                sets: []
            )
            for (setIndex, setDraft) in draft.sets.enumerated() {
                let set = WorkoutSetModel(
                    exercise: exercise,
                    setNumber: setIndex + 1,
                    weight: Double(setDraft.weight) ?? 0,
                    repetitions: setDraft.repetitions,
                    duration: setDraft.duration,
                    distance: Double(setDraft.distance) ?? 0,
                    notes: setDraft.notes,
                    isCompleted: setDraft.isCompleted
                )
                exercise.sets.append(set)
            }
            rebuilt.append(exercise)
        }

        workout.exercises = rebuilt

        do {
            try context.save()
            dismiss()
        } catch {
            validationMessage = "Could not save changes. Please try again."
        }
    }

    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainder = seconds % 60
        return String(format: "%02d:%02d", minutes, remainder)
    }
}

#Preview {
    WorkoutDetailView(workout: WorkoutModel(user: UserModel(fullName: "Test", username: "test", email: "test@test.com", passwordHash: "hash"), workoutName: "Bench Press", workoutType: "Strength", date: Date(), duration: 45, sets: 4, repetitions: 8, notes: "Focus on control", isCompleted: true, sessionTitle: "Bench Press", exercises: []))
        .environmentObject(AuthManager())
}
