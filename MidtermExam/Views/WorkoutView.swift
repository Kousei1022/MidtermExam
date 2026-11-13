
import SwiftUI

struct WorkoutView: View {
    @State private var workoutType = "Upper Body"
    @State private var duration = 45
    @State private var completed = false
    @State private var showAlert = false

    private let workoutTypes = [
        "Upper Body",
        "Lower Body",
        "Full Body",
        "Cardio",
        "Mobility"
    ]

    private let sessions: [WorkoutSession] = [
        WorkoutSession(title: "Upper Body Power", duration: 45, focus: "Chest • Back • Arms", intensity: "High", completed: true),
        WorkoutSession(title: "Leg Day", duration: 50, focus: "Quads • Glutes • Hamstrings", intensity: "Moderate", completed: false),
        WorkoutSession(title: "Core & Conditioning", duration: 30, focus: "Abs • Stability • Cardio", intensity: "High", completed: true)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Training plan")
                            .font(.title2)
                            .fontWeight(.bold)

                        HStack(spacing: 14) {
                            WorkoutMetric(value: "4", label: "Sessions")
                            WorkoutMetric(value: "180", label: "Min")
                            WorkoutMetric(value: "5d", label: "Streak")
                        }
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Create workout")
                            .font(.title3)
                            .fontWeight(.semibold)

                        VStack(spacing: 12) {
                            Picker("Workout type", selection: $workoutType) {
                                ForEach(workoutTypes, id: \.self) { workout in
                                    Text(workout)
                                }
                            }
                            .pickerStyle(.segmented)

                            HStack {
                                Text("Duration")
                                    .fontWeight(.medium)
                                Spacer()
                                Stepper(value: $duration, in: 15...120, step: 15) {
                                    Text("\(duration) min")
                                }
                            }
                            .padding(.vertical, 2)

                            Toggle("Mark as completed", isOn: $completed)
                                .tint(.indigo)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                        Button {
                            showAlert = true
                        } label: {
                            Text("Add workout")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(LinearGradient(colors: [.indigo, .purple], startPoint: .leading, endPoint: .trailing))
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Upcoming sessions")
                            .font(.title3)
                            .fontWeight(.semibold)

                        ForEach(sessions) { session in
                            HStack(alignment: .center, spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(session.completed ? Color.green.opacity(0.12) : Color.indigo.opacity(0.12))
                                        .frame(width: 52, height: 52)

                                    Image(systemName: session.completed ? "checkmark.circle.fill" : "figure.strengthtraining.traditional")
                                        .foregroundStyle(session.completed ? .green : .indigo)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(session.title)
                                        .font(.headline)
                                    Text(session.focus)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("\(session.duration) min")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Text(session.intensity)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(12)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                    }
                }
                .padding()
            }
            .alert("Workout added!", isPresented: $showAlert) {
                Button("Done") { }
            } message: {
                Text("\(workoutType) • \(duration) minutes")
            }
            .navigationTitle("Workout")
        }
    }
}

private struct WorkoutMetric: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    WorkoutView()
}
