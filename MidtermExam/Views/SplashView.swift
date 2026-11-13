import SwiftUI

struct SplashView: View {
    @State private var showLogin = false
    @State private var showRegister = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [FitColors.background, Color(red: 0.05, green: 0.11, blue: 0.17)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 28) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(FitColors.primary)
                            .frame(width: 84, height: 84)

                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(.black)
                    }

                    Text("FitTrack")
                        .font(.system(size: 44, weight: .heavy))
                        .foregroundStyle(FitColors.primary)

                    Text("Build a healthier, stronger you.")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 250)

                    VStack(spacing: 14) {
                        FitButton(title: "Get Started") {
                            showRegister = true
                        }

                        Button {
                            showLogin = true
                        } label: {
                            Text("I already have an account")
                                .font(.system(size: 15, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .foregroundStyle(.white)
                                .background(Color.white.opacity(0.04))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                    }
                    .frame(maxWidth: 280)
                }
                .padding()
            }
            .navigationDestination(isPresented: $showLogin) {
                LoginView()
            }
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
            }
        }
    }
}

#Preview {
    SplashView()
}
