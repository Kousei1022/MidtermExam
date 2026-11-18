import SwiftUI
import SwiftData

struct RegisterView: View {
    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var fullName = ""
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var isRegistered = false
    @State private var isRegistering = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [FitColors.background, FitColors.backgroundSecondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 10) {
                        Capsule()
                            .fill(FitColors.primarySoft)
                            .frame(width: 64, height: 32)
                            .overlay(
                                Image(systemName: "sparkles")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(FitColors.primary)
                            )

                        Text("Create account")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Start tracking your progress from day one.")
                            .font(.system(size: 14))
                            .foregroundStyle(FitColors.textSecondary)
                    }

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

                        FitButton(title: isRegistering ? "Creating account..." : "Create account") {
                            Task { await handleRegister() }
                        }
                        .disabled(isRegistering)
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
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .bold))
                        Text("Back")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
    }

    private func handleRegister() async {
        guard !isRegistering else { return }
        isRegistering = true
        defer { isRegistering = false }

        let result = await authManager.register(
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
