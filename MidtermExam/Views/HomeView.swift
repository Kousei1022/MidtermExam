
import SwiftUI

struct HomeView: View {
    private let dateTitle: String = {
        Date().formatted(.dateTime.weekday(.wide).month(.wide).day().year())
    }()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Welcome back")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text("FitTrack")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundStyle(.primary)
                        }

                        Spacer()

                        Circle()
                            .fill(LinearGradient(colors: [.indigo, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 52, height: 52)
                            .overlay(
                                Image(systemName: "figure.run")
                                    .foregroundStyle(.white)
                                    .font(.title3)
                            )
                    }

                    Text(dateTitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    ZStack(alignment: .bottomTrailing) {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(LinearGradient(colors: [.indigo, .blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(height: 200)

                        VStack(alignment: .leading, spacing: 14) {
                            Text("CURRENT GOAL")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.8))
                                .tracking(1.2)

                            Text("Build Strength")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(.white)

                            Text("Stay consistent and keep your weekly momentum strong.")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.9))

                            ProgressView(value: 0.72)
                                .tint(.white)
                                .scaleEffect(x: 1, y: 1.2, anchor: .center)
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity, alignment: .leading)

                        CircularProgressRing(progress: 0.72)
                            .padding(22)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Today's summary")
                            .font(.title2)
                            .fontWeight(.bold)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                            StatCard(title: "Workouts", value: "03", subtitle: "This week", icon: "dumbbell.fill", accent: .indigo)
                            StatCard(title: "Calories", value: "1,240", subtitle: "burned", icon: "flame.fill", accent: .orange)
                            StatCard(title: "Protein", value: "92g", subtitle: "goal 120g", icon: "bolt.fill", accent: .mint)
                            StatCard(title: "Progress", value: "72%", subtitle: "on track", icon: "chart.bar.fill", accent: .cyan)
                        }
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Next workout")
                            .font(.title2)
                            .fontWeight(.bold)

                        HStack(alignment: .center, spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.indigo.opacity(0.12))
                                    .frame(width: 56, height: 56)

                                Image(systemName: "figure.strengthtraining.traditional")
                                    .font(.title3)
                                    .foregroundStyle(.indigo)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Upper Body Power")
                                    .font(.headline)
                                Text("Chest • Back • Arms")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text("45 min")
                                .font(.headline)
                                .foregroundStyle(.indigo)
                        }
                        .padding(16)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                }
                .padding()
            }
            .background(Color(.systemBackground))
            .navigationTitle("Overview")
        }
    }
}

private struct CircularProgressRing: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.25), lineWidth: 8)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.white, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))

            Text("72%")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(width: 78, height: 78)
    }
}

#Preview {
    HomeView()
}
