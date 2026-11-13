import SwiftUI

struct ProgressScreen: View {
    @State private var goal = "Build Muscle"

    private let goals = [
        "Build Muscle",
        "Lose Fat",
        "Maintain Weight",
        "Improve Fitness"
    ]

    private let weeklyProgress = [0.6, 0.72, 0.82, 0.68, 0.9, 0.78, 0.95]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Performance")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text("Your progress")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }

                    ZStack {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(LinearGradient(colors: [.indigo, .blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(height: 230)

                        VStack(alignment: .center, spacing: 12) {
                            Text("Weekly progress")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.8))

                            ProgressRing(progress: 0.72)

                            Text("72% complete")
                                .font(.title3)
                                .foregroundStyle(.white)
                                .fontWeight(.semibold)
                        }
                    }

                    HStack(spacing: 12) {
                        ProgressStat(value: "4", title: "Workouts")
                        ProgressStat(value: "180", title: "Minutes")
                        ProgressStat(value: "5d", title: "Streak")
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Fitness goal")
                            .font(.title3)
                            .fontWeight(.semibold)

                        Picker("Goal", selection: $goal) {
                            ForEach(goals, id: \.self) { goal in
                                Text(goal)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Momentum")
                            .font(.title3)
                            .fontWeight(.semibold)

                        HStack(alignment: .bottom, spacing: 10) {
                            ForEach(weeklyProgress.indices, id: \.self) { index in
                                VStack(spacing: 8) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(index == weeklyProgress.indices.last ? Color.indigo : Color.indigo.opacity(0.55))
                                        .frame(width: 18, height: CGFloat(weeklyProgress[index]) * 110)

                                    Text(["M", "T", "W", "T", "F", "S", "S"][index])
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 8)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .padding()
            }
            .navigationTitle("Progress")
        }
    }
}

private struct ProgressRing: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.25), lineWidth: 18)
                .frame(width: 150, height: 150)

            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(Color.white, style: StrokeStyle(lineWidth: 18, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 150, height: 150)

            Text("72%")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
        }
    }
}

private struct ProgressStat: View {
    let value: String
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(title)
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
    ProgressScreen()
}
