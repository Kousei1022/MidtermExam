import SwiftUI
import SwiftData

struct EditProfileView: View {
    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss

    @State private var fullName: String
    @State private var email: String
    @State private var height: String
    @State private var weight: String
    @State private var fitnessGoal: String
    @State private var isSaving = false
    @State private var errorMessage: String?

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

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("YOUR PROFILE")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(FitColors.primary)
                        Text("Edit profile")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(.white)
                    }

                    FitFormSection(title: "Personal details", icon: "person.fill") {
                        FitTextField(title: "Full name", text: $fullName)
                        FitTextField(title: "Email", text: $email, keyboardType: .emailAddress)
                    }

                    FitFormSection(title: "Body metrics", icon: "scalemass.fill") {
                        FitTextField(title: "Height (cm)", text: $height, keyboardType: .decimalPad)
                        FitTextField(title: "Weight (kg)", text: $weight, keyboardType: .decimalPad)
                    }

                    FitFormSection(title: "Fitness goal", icon: "scope") {
                        Menu {
                            ForEach(goals, id: \.self) { goal in
                                Button {
                                    fitnessGoal = goal
                                } label: {
                                    if fitnessGoal == goal {
                                        Label(goal, systemImage: "checkmark")
                                    } else {
                                        Text(goal)
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text(fitnessGoal)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(.black)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.black.opacity(0.65))
                            }
                            .padding(.horizontal, 14)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(Color(red: 0.96, green: 0.97, blue: 0.99))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(FitColors.danger)
                    }

                    FitButton(title: isSaving ? "Saving..." : "Save changes") {
                        Task { await saveChanges() }
                    }
                    .disabled(isSaving)
                }
                .padding(20)
            }
        }
    }

    private func saveChanges() async {
        guard !isSaving else { return }
        isSaving = true
        defer { isSaving = false }
        errorMessage = await authManager.updateProfile(
            fullName: fullName,
            email: email,
            height: Double(height),
            weight: Double(weight),
            fitnessGoal: fitnessGoal
        )
        if errorMessage == nil {
            dismiss()
        }
    }
}

#Preview {
    EditProfileView(user: UserModel(fullName: "Test User", username: "test", email: "test@example.com", passwordHash: "preview"))
        .environmentObject(AuthManager())
}
