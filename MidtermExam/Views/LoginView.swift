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
    @State private var isAuthenticated = false
    @State private var isSigningIn = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [FitColors.background, Color(red: 0.05, green: 0.10, blue: 0.15)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Welcome back")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)

                    Text("Sign in to continue your fitness journey.")
                        .font(.system(size: 14))
                        .foregroundStyle(FitColors.textSecondary)

                    VStack(spacing: 14) {
                        FitTextField(title: "Email", text: $emailOrUsername, keyboardType: .emailAddress)
                        HStack {
                            if isPasswordVisible {
                                TextField("Password", text: $password)
                            } else {
                                SecureField("Password", text: $password)
                            }
                            Button {
                                isPasswordVisible.toggle()
                            } label: {
                                Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                    .foregroundStyle(FitColors.textSecondary)
                            }
                        }
                        .padding(12)
                        .background(Color.white.opacity(0.04))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )

                        HStack {
                            Toggle("Remember me", isOn: $rememberMe)
                                .toggleStyle(.switch)
                                .tint(FitColors.primary)
                            Spacer()
                            Button("Forgot password?") {
                            }
                            .foregroundStyle(FitColors.primary)
                        }

                        if let errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(FitColors.danger)
                        }

                        FitButton(title: isSigningIn ? "Signing in..." : "Log In") {
                            Task { await handleLogin() }
                        }
                        .disabled(isSigningIn)

                        NavigationLink(destination: RegisterView()) {
                            Text("Create account")
                                .font(.system(size: 15, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .foregroundStyle(.white)
                                .background(Color.white.opacity(0.04))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
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
            isAuthenticated = false
        } else {
            errorMessage = nil
            isAuthenticated = true
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager())
}
