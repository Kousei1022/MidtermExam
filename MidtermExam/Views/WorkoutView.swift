import SwiftUI
import SwiftData

struct WorkoutView: View {
    @EnvironmentObject private var authManager: AuthManager
    @Query(sort: \WorkoutModel.date, order: .reverse) private var allWorkouts: [WorkoutModel]
    @State private var selectedFilter = SessionFilter.all

    private var sessions: [WorkoutModel] {
        guard let user = authManager.currentUser else { return [] }
        return allWorkouts.filter { $0.user?.id == user.id }
    }

    private var visibleSessions: [WorkoutModel] {
        switch selectedFilter {
        case .all:
            return sessions
        case .planned:
            return sessions.filter { !$0.isCompleted }
        case .completed:
            return sessions.filter(\.isCompleted)
        }
    }

    private var totalMinutes: Int {
        sessions.filter { $0.isCompleted }.reduce(0) { $0 + $1.duration }
    }

    private var totalExercises: Int {
        sessions.reduce(0) { $0 + $1.totalExerciseCount }
    }

    private var totalSets: Int {
        sessions.reduce(0) { $0 + $1.totalSetsCount }
    }

    private var totalVolume: Int {
        sessions.reduce(0) { $0 + $1.totalVolume }
    }

    private var thisWeeksSessions: [WorkoutModel] {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return sessions.filter { $0.date >= weekAgo }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [FitColors.background, FitColors.backgroundSecondary], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("TRAINING")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(FitColors.primary)
                            Text("Workout dashboard")
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }

                        NavigationLink(destination: AddWorkoutView()) {
                            Label("Log workout", systemImage: "plus")
                                .font(.system(size: 15, weight: .bold))
                                .frame(maxWidth: .infinity, minHeight: 52)
                                .foregroundStyle(.black)
                                .background(
                                    LinearGradient(colors: [FitColors.primary, FitColors.primary.opacity(0.9)], startPoint: .top, endPoint: .bottom)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .shadow(color: FitColors.primary.opacity(0.30), radius: 10, x: 0, y: 8)
                        }

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            StatCard(title: "Today", value: "\(todayWorkoutsCount)", subtitle: "Sessions", icon: "calendar.badge.clock", accent: FitColors.primary)
                            StatCard(title: "Exercises", value: "\(totalExercises)", subtitle: "All time", icon: "dumbbell.fill", accent: FitColors.secondary)
                            StatCard(title: "Sets", value: "\(totalSets)", subtitle: "Completed", icon: "list.number", accent: .orange)
                            StatCard(title: "Minutes", value: "\(totalMinutes)", subtitle: "Training", icon: "clock.fill", accent: FitColors.success)
                            StatCard(title: "Volume", value: "\(totalVolume)", subtitle: "kg", icon: "scalemass.fill", accent: .cyan)
                            StatCard(title: "Status", value: "\(sessions.filter(\.isCompleted).count)/\(max(1, sessions.count))", subtitle: "Completed", icon: "checkmark.circle.fill", accent: FitColors.primary)
                        }

                        FitCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Weekly progress")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(.white)
                                    Spacer()
                                    Text("\(thisWeeksSessions.count) sessions")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(FitColors.primary)
                                }

                                let progress = min(1.0, Double(thisWeeksSessions.count) / 4.0)
                                ProgressView(value: progress)
                                    .tint(FitColors.primary)
                                Text("Keep your current streak going with at least four workouts this week.")
                                    .font(.system(size: 12))
                                    .foregroundStyle(FitColors.textSecondary)
                            }
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent workout history")
                                .font(.system(size: 19, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)

                            Picker("Filter sessions", selection: $selectedFilter) {
                                ForEach(SessionFilter.allCases) { filter in
                                    Text(filter.title).tag(filter)
                                }
                            }
                            .pickerStyle(.segmented)
                            .tint(FitColors.primary)
                        }

                        if visibleSessions.isEmpty {
                            FitCard {
                                VStack(alignment: .leading, spacing: 8) {
                                    Image(systemName: selectedFilter == .all ? "figure.strengthtraining.traditional" : "line.3.horizontal.decrease.circle")
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundStyle(FitColors.primary)
                                    Text(selectedFilter == .all ? "No workout sessions yet" : "No matching sessions")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(.white)
                                    Text(selectedFilter == .all ? "Create a workout session and your dashboard will populate with exercise data." : "Adjust the filter to see more training records.")
                                        .font(.system(size: 13))
                                        .foregroundStyle(FitColors.textSecondary)
                                }
                            }
                        } else {
                            LazyVStack(spacing: 10) {
                                ForEach(visibleSessions) { session in
                                    NavigationLink(destination: WorkoutDetailView(workout: session)) {
                                        WorkoutSessionRow(session: session)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
        }
    }

    private var todayWorkoutsCount: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return sessions.filter { Calendar.current.isDate($0.date, inSameDayAs: today) }.count
    }
}

private enum SessionFilter: String, CaseIterable, Identifiable {
    case all
    case planned
    case completed

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:
            return "All"
        case .planned:
            return "Planned"
        case .completed:
            return "Done"
        }
    }
}

private struct WorkoutSessionRow: View {
    let session: WorkoutModel

    var body: some View {
        FitCard {
            HStack(spacing: 12) {
                Image(systemName: session.isCompleted ? "checkmark.circle.fill" : "figure.strengthtraining.traditional")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(session.isCompleted ? FitColors.success : FitColors.primary)
                    .frame(width: 42, height: 42)
                    .background(FitColors.panelAlt)
                    .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(session.workoutName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text("\(session.totalExerciseCount) exercises · \(session.totalSetsCount) sets · \(session.date.formatted(.dateTime.month(.abbreviated).day()))")
                        .font(.system(size: 12))
                        .foregroundStyle(FitColors.textSecondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 4)
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(session.duration) min")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                    Text(session.isCompleted ? "Done" : "Planned")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(session.isCompleted ? FitColors.success : FitColors.primary)
                }
            }
        }
    }
}

#Preview {
    WorkoutView()
        .environmentObject(AuthManager())
}
