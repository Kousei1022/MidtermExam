import SwiftUI
import SwiftData

struct EditProfileView: View {
    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var fullName: String
    @State private var email: String
    @State private var height: String
    @State private var weight: String
    @State private var fitnessGoal: String

    init(user: UserModel) {
        _fullName = State(initialValue: user.fullName)
        _email = State(initialValue: user.email)
        _height = State(initialValue: user.height > 0 ? user.height.formatted() : "")
        _weight = State(initialValue: user.weight > 0 ? user.weight.formatted() : "")
        _fitnessGoal = State(initialValue: user.fitnessGoal)
    }

    private let goals = ["Build Muscle", "Lose Fat", "Maintain Weight", "Improve Fitness"]

    var body: some View {
        ZStack {
            LinearGradient(colors: [FitColors.background, Color(red: 0.05, green: 0.08, blue: 0.14)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Text("Edit Profile")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)

                FitTextField(title: "Full name", text: $fullName)
                FitTextField(title: "Email", text: $email, keyboardType: .emailAddress)
                FitTextField(title: "Height (cm)", text: $height, keyboardType: .decimalPad)
                FitTextField(title: "Weight (kg)", text: $weight, keyboardType: .decimalPad)

                Picker("Fitness goal", selection: $fitnessGoal) {
                    ForEach(goals, id: \ .self) { goal in
                        Text(goal).tag(goal)
                    }
                }
                .pickerStyle(.segmented)

                FitButton(title: "Save changes") {
                    saveChanges()
                }
            }
            .padding(20)
        }
    }

    private func saveChanges() {
        guard let user = authManager.currentUser else { return }
        user.fullName = fullName
        user.email = email.lowercased()
        user.height = Double(height) ?? user.height
        user.weight = Double(weight) ?? user.weight
        user.fitnessGoal = fitnessGoal
        try? context.save()
        dismiss()
    }
}

#Preview {
    EditProfileView(user: UserModel(fullName: "Test User", username: "test", email: "test@example.com", passwordHash: "preview"))
        .environmentObject(AuthManager())
}
