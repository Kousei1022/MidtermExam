import SwiftUI
import SwiftData

struct RegisterView: View {
    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.modelContext) private var modelContext

    @State private var fullName = ""
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var isRegistered = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [FitColors.background, Color(red: 0.04, green: 0.09, blue: 0.13)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Create account")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)

                    Text("Start tracking your progress from day one.")
                        .font(.system(size: 14))
                        .foregroundStyle(FitColors.textSecondary)

                    VStack(spacing: 14) {
                        FitTextField(title: "Full name", text: $fullName)
                        FitTextField(title: "Username", text: $username)
                        FitTextField(title: "Email", text: $email, keyboardType: .emailAddress)
                        FitTextField(title: "Password", text: $password, isSecure: true)
                        FitTextField(title: "Confirm password", text: $confirmPassword, isSecure: true)

                        if let errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(FitColors.danger)
                        }

                        FitButton(title: "Create account") {
                            handleRegister()
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            authManager.configure(modelContext: modelContext)
        }
        .fullScreenCover(isPresented: $isRegistered) {
            MainTabView(currentUser: authManager.currentUser ?? UserModel(fullName: "", username: "", email: "", passwordHash: ""))
        }
    }

    private func handleRegister() {
        let result = authManager.register(
            fullName: fullName,
            username: username,
            email: email,
            password: password,
            confirmPassword: confirmPassword
        )

        if let result {
            errorMessage = result
            isRegistered = false
        } else {
            errorMessage = nil
            isRegistered = true
        }
    }
}

#Preview {
    RegisterView()
        .environmentObject(AuthManager())
}
