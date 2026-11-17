import SwiftUI
import SwiftData

struct LoginView: View {
    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.modelContext) private var modelContext
    @State private var emailOrUsername = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var rememberMe = true
    @State private var errorMessage: String?
    @State private var resetMessage: String?
    @State private var isAuthenticated = false
    @State private var isSigningIn = false
    @State private var isSendingReset = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [FitColors.background, FitColors.backgroundSecondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Capsule()
                            .fill(FitColors.primarySoft)
                            .frame(width: 64, height: 32)
                            .overlay(
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(FitColors.primary)
                            )

                        Text("Welcome back")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Sign in to continue your fitness journey.")
                            .font(.system(size: 14))
                            .foregroundStyle(FitColors.textSecondary)
                    }
                    .padding(.top, 20)

                    VStack(spacing: 14) {
                        FitTextField(title: "Email or username", text: $emailOrUsername, keyboardType: .emailAddress)

                        HStack {
                            Group {
                                if isPasswordVisible {
                                    TextField("", text: $password, prompt: Text("Password").foregroundStyle(FitColors.placeholder))
                                } else {
                                    SecureField("", text: $password, prompt: Text("Password").foregroundStyle(FitColors.placeholder))
                                }
                            }
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(FitColors.text)
                            .accentColor(FitColors.primary)
                            .tint(FitColors.primary)

                            Button {
                                isPasswordVisible.toggle()
                            } label: {
                                Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                    .foregroundStyle(FitColors.textSecondary)
                            }
                        }
                        .font(.system(size: 15, weight: .medium))
                        .padding(14)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .background(Color.white.opacity(0.04))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(FitColors.border, lineWidth: 1)
                        )

                        HStack {
                            Toggle("Remember me", isOn: $rememberMe)
                                .toggleStyle(.switch)
                                .tint(FitColors.primary)
                            Spacer()
                            Button(isSendingReset ? "Sending..." : "Forgot password?") {
                                Task { await handleForgotPassword() }
                            }
                            .disabled(isSendingReset)
                            .foregroundStyle(FitColors.primary)
                        }

                        if let errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(FitColors.danger)
                        }

                        if let resetMessage {
                            Text(resetMessage)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(FitColors.primary)
                        }

                        FitButton(title: isSigningIn ? "Signing in..." : "Log In") {
                            Task { await handleLogin() }
                        }
                        .disabled(isSigningIn)

                        NavigationLink(destination: RegisterView()) {
                            Text("Create account")
                                .font(.system(size: 15, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .foregroundStyle(.white)
                                .background(Color.white.opacity(0.04))
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(FitColors.border, lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 30)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            authManager.configure(modelContext: modelContext)
        }
        .fullScreenCover(isPresented: $isAuthenticated) {
            MainTabView(currentUser: authManager.currentUser ?? UserModel(fullName: "", username: "", email: "", passwordHash: ""))
        }
    }

    private func handleLogin() async {
        guard !isSigningIn else { return }
        isSigningIn = true
        defer { isSigningIn = false }

        let result = await authManager.login(emailOrUsername: emailOrUsername, password: password)
        if let result {
            errorMessage = result
            resetMessage = nil
            isAuthenticated = false
        } else {
            errorMessage = nil
            resetMessage = nil
            isAuthenticated = true
        }
    }

    private func handleForgotPassword() async {
        guard !isSendingReset else { return }
        let email = emailOrUsername.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !email.isEmpty, email.contains("@") else {
            resetMessage = nil
            errorMessage = "Enter your email address to reset your password."
            return
        }

        isSendingReset = true
        defer { isSendingReset = false }

        if let user = try? modelContext.fetch(FetchDescriptor<UserModel>()).first(where: { $0.email.lowercased() == email.lowercased() }) {
            errorMessage = nil
            resetMessage = "Password reset is available for local accounts. Use the same email to sign in again."
            print("Local password reminder for: \(user.email)")
        } else {
            errorMessage = "No local account was found for that email. Create an account first."
            resetMessage = nil
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager())
}
