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
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)

            Text(subtitle)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(FitColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .frame(minHeight: 150, alignment: .topLeading)
        .background(FitColors.panel)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(FitColors.border, lineWidth: 1)
        )
    }
}

#Preview {
    StatCard(title: "Workouts", value: "03", subtitle: "This week", icon: "dumbbell.fill", accent: .indigo)
        .padding()
}

