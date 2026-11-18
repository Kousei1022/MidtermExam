import SwiftUI

struct SplashView: View {
    @State private var showLogin = false
    @State private var showRegister = false
    @State private var showContent = false

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(red: 0.027, green: 0.067, blue: 0.114),
                            Color(red: 0.063, green: 0.118, blue: 0.176)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()

                    SplashDecorations(size: proxy.size)

                    VStack(spacing: 0) {
                        Spacer(minLength: 28)

                        VStack(spacing: 18) {
                            ZStack {
                                Circle()
                                    .fill(FitColors.primary.opacity(showContent ? 0.18 : 0.08))
                                    .frame(width: 152, height: 152)
                                    .blur(radius: 24)
                                    .scaleEffect(showContent ? 1.08 : 0.92)
                                    .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true), value: showContent)

                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.14), Color.white.opacity(0.04)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 92, height: 92)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                                            .stroke(FitColors.primary.opacity(0.48), lineWidth: 1)
                                    )
                                    .overlay(
                                        Image(systemName: "dumbbell.fill")
                                            .font(.system(size: 38, weight: .bold))
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [FitColors.primary, Color(red: 0.78, green: 1.0, blue: 0.68)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                    )
                                    .shadow(color: FitColors.primary.opacity(0.34), radius: 24, x: 0, y: 10)
                            }
                            .scaleEffect(showContent ? 1 : 0.82)
                            .opacity(showContent ? 1 : 0)

                            HStack(spacing: 0) {
                                Text("Fit")
                                    .foregroundStyle(.white)
                                Text("Track")
                                    .foregroundStyle(FitColors.primary)
                            }
                            .font(.system(size: 43, weight: .heavy, design: .rounded))
                            .tracking(-1)
                            .shadow(color: .black.opacity(0.24), radius: 8, x: 0, y: 5)
                        }
                        .offset(y: showContent ? 0 : 18)

                        Spacer(minLength: 20)

                        VStack(alignment: .center, spacing: 28) {
                            VStack(spacing: 10) {
                                Text("Your fitness journey.")
                                Text("Your goals. Your progress.")
                            }
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)

                            Text("Build stronger habits, track every workout,\nand become your best self.")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(FitColors.textSecondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .frame(maxWidth: 300)

                            VStack(spacing: 12) {
                                SplashPrimaryButton(title: "Get Started") {
                                    showRegister = true
                                }

                                SplashSecondaryButton(title: "Already have an account") {
                                    showLogin = true
                                }
                            }
                            .frame(maxWidth: min(proxy.size.width - 48, 360))
                        }
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 24)
                        .padding(.bottom, max(proxy.safeAreaInsets.bottom, 20) + 8)

                        Spacer(minLength: 18)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 24)
                }
            }
            .navigationDestination(isPresented: $showLogin) {
                LoginView()
            }
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
            }
            .onAppear {
                withAnimation(.spring(response: 0.75, dampingFraction: 0.82)) {
                    showContent = true
                }
            }
        }
    }
}

private struct SplashDecorations: View {
    let size: CGSize

    var body: some View {
        ZStack {
            Circle()
                .fill(FitColors.primary.opacity(0.10))
                .frame(width: size.width * 0.62, height: size.width * 0.62)
                .blur(radius: 55)
                .offset(x: size.width * 0.30, y: -size.height * 0.30)

            Circle()
                .fill(Color(red: 0.20, green: 0.42, blue: 0.58).opacity(0.12))
                .frame(width: size.width * 0.48, height: size.width * 0.48)
                .blur(radius: 40)
                .offset(x: -size.width * 0.42, y: size.height * 0.24)

            Path { path in
                path.move(to: CGPoint(x: size.width * 0.10, y: size.height * 0.17))
                path.addQuadCurve(
                    to: CGPoint(x: size.width * 0.78, y: size.height * 0.27),
                    control: CGPoint(x: size.width * 0.52, y: size.height * 0.08)
                )
            }
            .stroke(Color.white.opacity(0.035), lineWidth: 1)

            ForEach(0..<6, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(FitColors.primary.opacity(0.06))
                    .frame(width: 22, height: 3)
                    .rotationEffect(.degrees(-18))
                    .offset(
                        x: size.width * (0.12 + CGFloat(index % 3) * 0.24) - size.width * 0.5,
                        y: size.height * (0.12 + CGFloat(index / 3) * 0.58)
                    )
            }
        }
        .ignoresSafeArea()
    }
}

private struct SplashPrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Spacer()
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color(red: 0.055, green: 0.085, blue: 0.105))
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color(red: 0.055, green: 0.085, blue: 0.105))
            }
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(
                LinearGradient(
                    colors: [FitColors.primary, Color(red: 0.76, green: 0.96, blue: 0.58)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: FitColors.primary.opacity(0.24), radius: 16, x: 0, y: 8)
        }
        .buttonStyle(SplashPressButtonStyle())
    }
}

private struct SplashSecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Spacer()
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
            }
            .frame(maxWidth: .infinity, minHeight: 56)
            .foregroundStyle(.white)
            .background(Color.white.opacity(0.045))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
        }
        .buttonStyle(SplashPressButtonStyle())
    }
}

private struct SplashPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.88 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

#Preview {
    SplashView()
}
