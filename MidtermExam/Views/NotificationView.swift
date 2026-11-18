import SwiftUI

struct NotificationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var workoutReminders = true
    @State private var mealReminders = true
    @State private var progressUpdates = true
    @State private var motivationalMessages = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [FitColors.background, Color(red: 0.05, green: 0.08, blue: 0.14)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                Text("Notifications")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)

                ToggleRow(label: "Workout reminders", isOn: $workoutReminders)
                ToggleRow(label: "Meal reminders", isOn: $mealReminders)
                ToggleRow(label: "Progress updates", isOn: $progressUpdates)
                ToggleRow(label: "Motivational messages", isOn: $motivationalMessages)
            }
            .padding(20)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            FitBackButton(dismiss: dismiss)
        }
    }
}

private struct ToggleRow: View {
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white)
            Spacer()
            Toggle("", isOn: $isOn)
                .tint(FitColors.primary)
                .labelsHidden()
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    NotificationView()
}
