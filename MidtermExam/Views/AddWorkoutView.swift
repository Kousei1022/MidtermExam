import SwiftUI
import SwiftData
import Combine

struct AddWorkoutView: View {
    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var sessionName = ""
    @State private var workoutDate = Date()
    @State private var exercises: [ExerciseDraft] = [ExerciseDraft()]
    @State private var validationMessage: String?
    @State private var isWorkoutStarted = false
    @State private var timerSeconds = 0
    @State private var timerRunning = false
    @State private var restSeconds = 0
    @State private var restTimerRunning = false
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var isSaving = false

    private let exerciseLibrary = [
        ExerciseLibraryItem(name: "Bench Press", category: "Chest"),
        ExerciseLibraryItem(name: "Incline Dumbbell Press", category: "Chest"),
        ExerciseLibraryItem(name: "Barbell Row", category: "Back"),
        ExerciseLibraryItem(name: "Pull-up", category: "Back"),
        ExerciseLibraryItem(name: "Overhead Press", category: "Shoulders"),
        ExerciseLibraryItem(name: "Lateral Raise", category: "Shoulders"),
        ExerciseLibraryItem(name: "Barbell Curl", category: "Biceps"),
        ExerciseLibraryItem(name: "Hammer Curl", category: "Biceps"),
        ExerciseLibraryItem(name: "Tricep Pushdown", category: "Triceps"),
        ExerciseLibraryItem(name: "Skull Crusher", category: "Triceps"),
        ExerciseLibraryItem(name: "Squat", category: "Legs"),
        ExerciseLibraryItem(name: "Romanian Deadlift", category: "Legs"),
        ExerciseLibraryItem(name: "Hip Thrust", category: "Glutes"),
        ExerciseLibraryItem(name: "Walking Lunges", category: "Glutes"),
        ExerciseLibraryItem(name: "Plank", category: "Abs"),
        ExerciseLibraryItem(name: "Cable Crunch", category: "Abs"),
        ExerciseLibraryItem(name: "Running", category: "Cardio"),
        ExerciseLibraryItem(name: "Cycling", category: "Cardio"),
        ExerciseLibraryItem(name: "Burpees", category: "Full Body"),
        ExerciseLibraryItem(name: "Kettlebell Swing", category: "Full Body")
    ]

    private let categories = ["All", "Chest", "Back", "Shoulders", "Biceps", "Triceps", "Legs", "Glutes", "Abs", "Cardio", "Full Body"]
    private let restOptions = [30, 60, 90, 120]

    private var filteredLibrary: [ExerciseLibraryItem] {
        exerciseLibrary.filter { item in
            let matchesCategory = selectedCategory == "All" || item.category == selectedCategory
            let matchesSearch = searchText.isEmpty || item.name.lowercased().contains(searchText.lowercased())
            return matchesCategory && matchesSearch
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [FitColors.background, FitColors.backgroundSecondary], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("TRAINING SESSION")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(FitColors.primary)
                        Text("Create workout")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Track all exercises, sets, and progress for this session.")
                            .font(.system(size: 13))
                            .foregroundStyle(FitColors.textSecondary)
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
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Workout timer")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.white)
                                Spacer()
                                Button(timerRunning ? "Pause" : "Start") {
                                    isWorkoutStarted = true
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
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundStyle(FitColors.primary)
                                .monospacedDigit()
                        }
                    }

                    FitCard {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Rest timer")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.white)
                                Spacer()
                                Button(restTimerRunning ? "Pause" : "Start") {
                                    restTimerRunning.toggle()
                                }
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(FitColors.secondary)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }

                            Text(formatDuration(restSeconds))
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(FitColors.secondary)
                                .monospacedDigit()

                            HStack(spacing: 8) {
                                ForEach(restOptions, id: \ .self) { option in
                                    Button("\(option)s") {
                                        restSeconds = option
                                        restTimerRunning = false
                                    }
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .background(FitColors.panelAlt)
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Exercises")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Spacer()
                            Button {
                                exercises.append(ExerciseDraft())
                            } label: {
                                Label("Add exercise", systemImage: "plus")
                                    .font(.system(size: 13, weight: .semibold))
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
                                onRemove: {
                                    exercises.remove(at: index)
                                },
                                onAddSet: {
                                    exercises[index].sets.append(SetDraft())
                                },
                                onRemoveSet: { setIndex in
                                    if exercises[index].sets.count > 1 {
                                        exercises[index].sets.remove(at: setIndex)
                                    }
                                },
                                library: filteredLibrary,
                                selectedCategory: $selectedCategory,
                                searchText: $searchText,
                                onSelectLibraryItem: { item in
                                    exercises[index].name = item.name
                                    exercises[index].muscleGroup = item.category
                                }
                            )
                        }
                    }

                    if let validationMessage {
                        Text(validationMessage)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(FitColors.danger)
                    }

                    FitButton(title: isSaving ? "Saving..." : "Save workout") {
                        saveWorkout()
                    }
                    .padding(.top, 8)
                }
                .padding(20)
            }
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if timerRunning {
                timerSeconds += 1
            }
            if restTimerRunning {
                if restSeconds > 0 {
                    restSeconds -= 1
                } else {
                    restTimerRunning = false
                }
            }
        }
        .navigationBarBackButtonHidden(false)
    }

    private func saveWorkout() {
        guard let user = authManager.currentUser else {
            validationMessage = "Please sign in before saving a workout."
            return
        }

        let filteredExercises = exercises.filter { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        guard !filteredExercises.isEmpty else {
            validationMessage = "Add at least one exercise before saving."
            return
        }

        var totalExerciseDuration = 0
        var cleanExercises: [WorkoutExerciseModel] = []

        for (index, draft) in filteredExercises.enumerated() {
            let exercise = WorkoutExerciseModel(
                workout: nil,
                exerciseName: draft.name,
                muscleGroup: draft.muscleGroup,
                notes: draft.notes,
                duration: draft.duration,
                distance: Double(draft.distance) ?? 0,
                orderIndex: index,
                sets: []
            )

            totalExerciseDuration += draft.duration

            for (setIndex, setDraft) in draft.sets.enumerated() {
                let sanitizedWeight = Double(setDraft.weight) ?? 0
                let sanitizedReps = setDraft.repetitions
                let sanitizedDuration = setDraft.duration
                let setModel = WorkoutSetModel(
                    exercise: nil,
                    setNumber: setIndex + 1,
                    weight: sanitizedWeight,
                    repetitions: sanitizedReps,
                    duration: sanitizedDuration,
                    distance: Double(setDraft.distance) ?? 0,
                    notes: setDraft.notes
                )
                exercise.sets.append(setModel)
            }

            cleanExercises.append(exercise)
        }

        let sessionTitle = sessionName.trimmingCharacters(in: .whitespacesAndNewlines)
        let workout = WorkoutModel(
            user: user,
            workoutName: sessionTitle.isEmpty ? "Workout Session" : sessionTitle,
            workoutType: filteredExercises.first?.muscleGroup ?? "Training",
            date: workoutDate,
            duration: max(timerSeconds / 60, totalExerciseDuration),
            sets: filteredExercises.reduce(0) { $0 + $1.sets.count },
            repetitions: filteredExercises.reduce(0) { total, exercise in
                total + exercise.sets.reduce(0) { $0 + $1.repetitions }
            },
            notes: "",
            isCompleted: true,
            sessionTitle: sessionTitle.isEmpty ? "Workout Session" : sessionTitle,
            exercises: cleanExercises
        )

        for exercise in cleanExercises {
            exercise.workout = workout
        }

        context.insert(workout)
        try? context.save()
        dismiss()
    }

    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainder = seconds % 60
        return String(format: "%02d:%02d", minutes, remainder)
    }
}

struct ExerciseEditorCard: View {
    let exerciseIndex: Int
    @Binding var exercise: ExerciseDraft
    let onRemove: () -> Void
    let onAddSet: () -> Void
    let onRemoveSet: (Int) -> Void
    let library: [ExerciseLibraryItem]
    @Binding var selectedCategory: String
    @Binding var searchText: String
    let onSelectLibraryItem: (ExerciseLibraryItem) -> Void

    var body: some View {
        FitCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Exercise \(exerciseIndex + 1)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(FitColors.primary)
                    Spacer()
                    Button(role: .destructive) {
                        onRemove()
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(FitColors.danger)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Exercise name")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(FitColors.textSecondary)
                    TextField("", text: $exercise.name, prompt: Text("Exercise name").foregroundStyle(FitColors.placeholder))
                        .padding(12)
                        .background(Color.white.opacity(0.04))
                        .foregroundStyle(FitColors.text)
                        .tint(FitColors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(FitColors.border, lineWidth: 1))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Exercise library")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(FitColors.textSecondary)

                    HStack(spacing: 8) {
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(["All", "Chest", "Back", "Shoulders", "Biceps", "Triceps", "Legs", "Glutes", "Abs", "Cardio", "Full Body"], id: \.self) { option in
                                Text(option).tag(option)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(FitColors.primary)
                    }

                    TextField("Search exercises", text: $searchText)
                        .padding(12)
                        .background(Color.white.opacity(0.04))
                        .foregroundStyle(FitColors.text)
                        .tint(FitColors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(FitColors.border, lineWidth: 1))

                    if !library.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(library.prefix(6), id: \.name) { item in
                                    Button(item.name) {
                                        onSelectLibraryItem(item)
                                    }
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                                    .background(FitColors.panelAlt)
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                }
                            }
                        }
                    }
                }

                HStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Muscle group")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(FitColors.textSecondary)
                        Picker("Muscle group", selection: $exercise.muscleGroup) {
                            ForEach(["Chest", "Back", "Shoulders", "Biceps", "Triceps", "Legs", "Glutes", "Abs", "Cardio", "Full Body"], id: \.self) { group in
                                Text(group).tag(group)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(FitColors.primary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Duration")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(FitColors.textSecondary)
                        TextField("0", text: Binding(
                            get: { String(exercise.duration) },
                            set: { exercise.duration = Int($0) ?? 0 }
                        ))
                        .keyboardType(.numberPad)
                        .padding(12)
                        .background(Color.white.opacity(0.04))
                        .foregroundStyle(FitColors.text)
                        .tint(FitColors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(FitColors.border, lineWidth: 1))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Distance")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(FitColors.textSecondary)
                        TextField("0", text: $exercise.distance)
                            .keyboardType(.decimalPad)
                            .padding(12)
                            .background(Color.white.opacity(0.04))
                            .foregroundStyle(FitColors.text)
                            .tint(FitColors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(FitColors.border, lineWidth: 1))
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(FitColors.textSecondary)
                    TextField("", text: $exercise.notes, prompt: Text("Session notes").foregroundStyle(FitColors.placeholder))
                        .padding(12)
                        .background(Color.white.opacity(0.04))
                        .foregroundStyle(FitColors.text)
                        .tint(FitColors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(FitColors.border, lineWidth: 1))
                }

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Sets")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                        Spacer()
                        Button {
                            onAddSet()
                        } label: {
                            Label("Add set", systemImage: "plus.circle.fill")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(FitColors.primary)
                        }
                    }

                    ForEach(Array(exercise.sets.enumerated()), id: \.offset) { setIndex, set in
                        HStack(alignment: .center, spacing: 8) {
                            Text("Set \(setIndex + 1)")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(FitColors.textSecondary)
                                .frame(width: 52, alignment: .leading)

                            TextField("kg", text: Binding(
                                get: { set.weight },
                                set: { exercise.sets[setIndex].weight = $0 }
                            ))
                            .keyboardType(.decimalPad)
                            .frame(maxWidth: 80)
                            .padding(10)
                            .background(Color.white.opacity(0.04))
                            .foregroundStyle(FitColors.text)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(FitColors.border, lineWidth: 1))

                            TextField("reps", text: Binding(
                                get: { String(set.repetitions) },
                                set: { exercise.sets[setIndex].repetitions = Int($0) ?? 0 }
                            ))
                            .keyboardType(.numberPad)
                            .frame(maxWidth: 70)
                            .padding(10)
                            .background(Color.white.opacity(0.04))
                            .foregroundStyle(FitColors.text)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(FitColors.border, lineWidth: 1))

                            Button(role: .destructive) {
                                onRemoveSet(setIndex)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(FitColors.danger)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct ExerciseDraft {
    var id = UUID()
    var name = ""
    var muscleGroup = "Chest"
    var notes = ""
    var duration = 0
    var distance = "0"
    var sets: [SetDraft] = [SetDraft()]
}

struct SetDraft {
    var id = UUID()
    var weight = "0"
    var repetitions = 0
    var duration = 0
    var distance = "0"
    var notes = ""
}

struct ExerciseLibraryItem {
    let name: String
    let category: String
}

#Preview {
    AddWorkoutView()
        .environmentObject(AuthManager())
}
