
import SwiftUI
import SwiftData

struct WorkoutView: View {
    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.modelContext) private var context

    @State private var workoutType = ""
    @State private var duration = 0
    @State private var completed = false
    @State private var showAlert = false
    @State private var sessions: [WorkoutModel] = []

    private let workoutTypes = [
        "Upper Body",
        "Lower Body",
        "Full Body",
        "Cardio",
        "Mobility"
    ]

    private var totalMinutes: Int {
        sessions.reduce(0) { $0 + $1.duration }
    }

    private var currentWeekCount: Int {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return sessions.filter { $0.date >= weekAgo }.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [FitColors.background, Color(red: 0.04, green: 0.08, blue: 0.14)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Workout")
                            .font(.system(size: 52, weight: .heavy))
                            .foregroundStyle(.white)

                        Text("Training plan")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.white)

                        HStack(spacing: 14) {
                            WorkoutMetric(value: "\(sessions.count)", label: "Sessions")
                            WorkoutMetric(value: "\(totalMinutes)", label: "Min")
                            WorkoutMetric(value: "\(currentWeekCount)d", label: "Streak")
                        }

                        VStack(alignment: .leading, spacing: 14) {
                            Text("Create workout")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundStyle(.white)

                            VStack(spacing: 12) {
                                Picker("Workout type", selection: $workoutType) {
                                    Text("Choose workout").tag("")
                                    ForEach(workoutTypes, id: \.self) { workout in
                                        Text(workout)
                                            .font(.system(size: 16))
                                            .tag(workout)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .tint(FitColors.primary)

                                HStack {
                                    Text("Duration")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundStyle(.white)
                                    Spacer()
                                    Stepper(value: $duration, in: 15...120, step: 15) {
                                        Text("\(duration) min")
                                            .font(.system(size: 18, weight: .medium))
                                            .foregroundStyle(.white)
                                    }
                                }

                                Toggle("Mark as completed", isOn: $completed)
                                    .tint(FitColors.primary)
                                    .foregroundStyle(.white)
                            }
                            .padding(16)
                            .background(Color(red: 0.17, green: 0.22, blue: 0.28).opacity(0.92))
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

                            NavigationLink(destination: AddWorkoutView()) {
                                Text("Add workout")
                                    .font(.system(size: 24, weight: .bold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .foregroundStyle(.white)
                                    .background(LinearGradient(colors: [Color(red: 0.52, green: 0.39, blue: 0.94), Color(red: 0.75, green: 0.46, blue: 0.90)], startPoint: .leading, endPoint: .trailing))
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                        }

                        VStack(alignment: .leading, spacing: 14) {
                            Text("Upcoming sessions")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundStyle(.white)

                            if sessions.isEmpty {
                                HStack {
                                    Text("No workouts logged yet")
                                        .font(.system(size: 16))
                                        .foregroundStyle(FitColors.textSecondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(18)
                                .background(Color(red: 0.17, green: 0.22, blue: 0.28).opacity(0.92))
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            } else {
                                ForEach(sessions.sorted { $0.date > $1.date }) { session in
                                    HStack(alignment: .center, spacing: 12) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(session.isCompleted ? Color.green.opacity(0.15) : Color.white.opacity(0.08))
                                                .frame(width: 52, height: 52)

                                            Image(systemName: session.isCompleted ? "checkmark.circle.fill" : "figure.strengthtraining.traditional")
                                                .font(.system(size: 22))
                                                .foregroundStyle(session.isCompleted ? .green : FitColors.primary)
                                        }

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(session.workoutName)
                                                .font(.system(size: 22, weight: .bold))
                                                .foregroundStyle(.white)
                                            Text("\(session.workoutType) • \(session.sets) sets")
                                                .font(.system(size: 16))
                                                .foregroundStyle(FitColors.textSecondary)
                                        }

                                        Spacer()

                                        VStack(alignment: .trailing, spacing: 4) {
                                            Text("\(session.duration) min")
                                                .font(.system(size: 17, weight: .semibold))
                                                .foregroundStyle(.white)
                                            Text(session.isCompleted ? "Done" : "Planned")
                                                .font(.system(size: 13, weight: .semibold))
                                                .foregroundStyle(session.isCompleted ? .green : FitColors.primary)
                                        }
                                    }
                                    .padding(14)
                                    .background(Color(red: 0.17, green: 0.22, blue: 0.28).opacity(0.92))
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .onAppear(perform: loadWorkouts)
            .alert("Workout saved", isPresented: $showAlert) {
                Button("Done") { }
            } message: {
                Text("\(workoutType) • \(duration) minutes")
            }
        }
    }

    private func loadWorkouts() {
        guard let user = authManager.currentUser else { return }
        sessions = DataManager.workouts(for: user, context: context).sorted { $0.date > $1.date }
    }

    private func saveWorkout() {
        guard let user = authManager.currentUser else { return }
        let selectedType = workoutType.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !selectedType.isEmpty, duration > 0 else { return }

        let workout = WorkoutModel(
            user: user,
            workoutName: selectedType,
            workoutType: selectedType,
            date: Date(),
            duration: duration,
            sets: 3,
            repetitions: 10,
            notes: "",
            isCompleted: completed
        )

        context.insert(workout)
        try? context.save()
        loadWorkouts()
        showAlert = true
    }
}

private struct WorkoutMetric: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(value)
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(FitColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(Color(red: 0.17, green: 0.22, blue: 0.28).opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

#Preview {
    WorkoutView()
        .environmentObject(AuthManager())
}
