import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(accent.opacity(0.12))
                        .frame(width: 38, height: 38)

                    Image(systemName: icon)
                        .foregroundStyle(accent)
                        .font(.headline)
                }

                Spacer()
            }

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

#Preview {
    StatCard(title: "Workouts", value: "03", subtitle: "This week", icon: "dumbbell.fill", accent: .indigo)
        .padding()
}

