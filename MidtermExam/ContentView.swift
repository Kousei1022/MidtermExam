import SwiftUI

struct ContentView: View {
    private let screens: [FitTrackScreen] = [
        .splash,
        .login,
        .home,
        .workout,
        .nutrition,
        .progress,
        .profile,
        .settings
    ]

    private let appTheme = AppTheme()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.07, blue: 0.13),
                    Color(red: 0.05, green: 0.11, blue: 0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(appTheme.accent)
                                    .frame(width: 52, height: 52)

                                Image(systemName: "dumbbell.fill")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(.black)
                            }
                        }

                        Text("FitTrack")
                            .font(.system(size: 48, weight: .heavy))
                            .foregroundStyle(appTheme.accent)

                        Text("Your Fitness Journey\nin One Place")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(.white)
                            .lineSpacing(4)

                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(menuItems, id: \ .title) { item in
                                HStack(spacing: 14) {
                                    Image(systemName: item.icon)
                                        .font(.system(size: 18, weight: .semibold))
                                        .frame(width: 22)
                                        .foregroundStyle(item.isSelected ? appTheme.accent : .white.opacity(0.75))

                                    Text(item.title)
                                        .font(.system(size: 16, weight: item.isSelected ? .semibold : .regular))
                                        .foregroundStyle(item.isSelected ? .white : .white.opacity(0.75))

                                    if item.caption != nil {
                                        Spacer()
                                        Text(item.caption ?? "")
                                            .font(.system(size: 12))
                                            .foregroundStyle(.white.opacity(0.55))
                                    }
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(item.isSelected ? Color.white.opacity(0.04) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }

                        HStack(spacing: 10) {
                            Text("Built with SwiftUI")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.white.opacity(0.75))
                            Spacer()
                            Circle()
                                .fill(appTheme.accent)
                                .frame(width: 8, height: 8)
                        }
                        .padding(.top, 4)
                    }
                    .frame(width: 260, alignment: .leading)

                    Spacer()
                }
                .padding(.top, 40)
                .padding(.leading, 32)

                ScrollView(.vertical) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 18) {
                        ForEach(screens, id: \ .id) { screen in
                            PhoneMockupView(screen: screen)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 24)
                }
            }
        }
    }

    private let menuItems: [(title: String, icon: String, isSelected: Bool, caption: String?)] = [
        ("Home", "house.fill", true, nil),
        ("Workout", "figure.strengthtraining.traditional", false, nil),
        ("Nutrition", "fork.knife", false, nil),
        ("Progress", "chart.bar.fill", false, nil),
        ("Profile", "person.fill", false, nil)
    ]
}

private struct AppTheme {
    let accent = Color(red: 0.12, green: 0.95, blue: 0.72)
    let cardBackground = Color(red: 0.03, green: 0.08, blue: 0.15)
    let elevatedCard = Color.white.opacity(0.05)
    let border = Color(red: 0.18, green: 0.78, blue: 0.88)
}

private struct PhoneMockupView: View {
    let screen: FitTrackScreen

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(red: 0.03, green: 0.08, blue: 0.15))
                .frame(width: 236, height: 500)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color(red: 0.18, green: 0.78, blue: 0.88), lineWidth: 1.5)
                )

            VStack(spacing: 0) {
                HStack {
                    Text("9:41")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                    HStack(spacing: 5) {
                        Image(systemName: "wifi")
                            .font(.system(size: 9))
                        Image(systemName: "battery.75")
                            .font(.system(size: 11))
                    }
                    .foregroundStyle(.white)
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)

                screen.content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 8)

                HStack(spacing: 10) {
                    ForEach(0..<4, id: \ .self) { index in
                        Image(systemName: screen.navIcons[index])
                            .font(.system(size: 14))
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(index == screen.activeTab ? Color(red: 0.12, green: 0.95, blue: 0.72) : .white.opacity(0.5))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
            .frame(width: 236, height: 500)
        }
    }
}

private enum FitTrackScreen: String, Identifiable {
    case splash, login, home, workout, nutrition, progress, profile, settings

    var id: String { rawValue }

    var content: some View {
        Group {
            switch self {
            case .splash:
                FitTrackSplashScreen()
            case .login:
                FitTrackLoginScreen()
            case .home:
                FitTrackHomeScreen()
            case .workout:
                FitTrackWorkoutScreen()
            case .nutrition:
                FitTrackNutritionScreen()
            case .progress:
                FitTrackProgressScreen()
            case .profile:
                FitTrackProfileScreen()
            case .settings:
                FitTrackSettingsScreen()
            }
        }
    }

    var navIcons: [String] {
        switch self {
        case .splash, .login:
            return ["house.fill", "figure.strengthtraining.traditional", "fork.knife", "chart.bar.fill"]
        case .home:
            return ["house.fill", "figure.strengthtraining.traditional", "fork.knife", "chart.bar.fill"]
        case .workout:
            return ["house.fill", "figure.strengthtraining.traditional", "fork.knife", "chart.bar.fill"]
        case .nutrition:
            return ["house.fill", "figure.strengthtraining.traditional", "fork.knife", "chart.bar.fill"]
        case .progress:
            return ["house.fill", "figure.strengthtraining.traditional", "fork.knife", "chart.bar.fill"]
        case .profile:
            return ["house.fill", "figure.strengthtraining.traditional", "fork.knife", "chart.bar.fill"]
        case .settings:
            return ["house.fill", "figure.strengthtraining.traditional", "fork.knife", "chart.bar.fill"]
        }
    }

    var activeTab: Int {
        switch self {
        case .home: return 0
        case .workout: return 1
        case .nutrition: return 2
        case .progress: return 3
        case .splash, .login, .profile, .settings: return 0
        }
    }
}

private struct FitTrackSplashScreen: View {
    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.12, green: 0.95, blue: 0.72))
                    .frame(width: 68, height: 68)

                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.black)
            }

            Text("FitTrack")
                .font(.system(size: 42, weight: .heavy))
                .foregroundStyle(Color(red: 0.12, green: 0.95, blue: 0.72))

            Text("Build a healthier, stronger you.")
                .font(.system(size: 15, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.8))
                .frame(width: 180)

            Button(action: {}) {
                Text("Get Started")
                    .font(.system(size: 15, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundStyle(.black)
                    .background(Color(red: 0.12, green: 0.95, blue: 0.72))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .frame(width: 150)
        }
        .padding(.bottom, 18)
    }
}

private struct FitTrackLoginScreen: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("FitTrack")
                .font(.system(size: 34, weight: .heavy))
                .foregroundStyle(Color(red: 0.12, green: 0.95, blue: 0.72))
                .padding(.top, 18)

            Text("Welcome back!")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)

            VStack(spacing: 10) {
                TextField("Email or Username", text: .constant(""))
                    .padding(10)
                    .background(Color.white.opacity(0.05))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                SecureField("Password", text: .constant(""))
                    .padding(10)
                    .background(Color.white.opacity(0.05))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            HStack {
                Toggle("", isOn: .constant(true))
                    .labelsHidden()
                    .tint(Color(red: 0.12, green: 0.95, blue: 0.72))
                Text("Remember me")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()
                Text("Forgot password?")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.7))
            }

            Button(action: {}) {
                Text("Log In")
                    .font(.system(size: 15, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundStyle(.black)
                    .background(Color(red: 0.12, green: 0.95, blue: 0.72))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Button(action: {}) {
                Text("Create Account")
                    .font(.system(size: 15, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundStyle(.white)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }
}

private struct FitTrackHomeScreen: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Welcome back!")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.7))
                    Text("FitTrack")
                        .font(.system(size: 32, weight: .heavy))
                        .foregroundStyle(Color(red: 0.12, green: 0.95, blue: 0.72))
                }
                Spacer()
                Image(systemName: "figure.run")
                    .font(.system(size: 28))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Current Goal")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white.opacity(0.65))
                Text("Build Muscle")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                ProgressView(value: 0.65)
                    .tint(Color(red: 0.12, green: 0.95, blue: 0.72))
                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(LinearGradient(colors: [.green.opacity(0.8), .mint.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Text("Today's Stats")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)

            HStack(spacing: 10) {
                StatTile(value: "3", label: "Workouts")
                StatTile(value: "1,240", label: "Calories")
            }
            HStack(spacing: 10) {
                StatTile(value: "92g", label: "Protein")
                StatTile(value: "65%", label: "Progress")
            }

            Text("Next Workout")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)

            HStack {
                Image(systemName: "figure.strengthtraining.traditional")
                    .foregroundStyle(.white)
                VStack(alignment: .leading) {
                    Text("Upper Body")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Chest • Back • Arms")
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.7))
                }
                Spacer()
                Text("45 min")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color(red: 0.12, green: 0.95, blue: 0.72))
            }
            .padding(10)
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }
}

private struct FitTrackWorkoutScreen: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Workout Planner")
                .font(.system(size: 23, weight: .bold))
                .foregroundStyle(.white)
                .padding(.top, 6)

            VStack(spacing: 10) {
                Picker("Workout", selection: .constant("Upper Body")) {
                    Text("Upper Body").tag("Upper Body")
                }
                .pickerStyle(.menu)
                .frame(height: 28)
                .padding(.horizontal, 8)
                .background(Color.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 10))

                HStack {
                    Text("Duration")
                        .foregroundStyle(.white)
                    Spacer()
                    Text("45 minutes")
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(8)
                .background(Color.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 10))

                Toggle("Workout Completed", isOn: .constant(true))
                    .tint(Color(red: 0.12, green: 0.95, blue: 0.72))
            }

            Button(action: {}) {
                Text("Add Workout")
                    .font(.system(size: 15, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundStyle(.black)
                    .background(Color(red: 0.12, green: 0.95, blue: 0.72))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }
}

private struct FitTrackNutritionScreen: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nutrition Tracker")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
                .padding(.top, 6)

            VStack(alignment: .leading, spacing: 6) {
                Text("Add Meal")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
                TextField("Food Name", text: .constant("Chicken Breast"))
                    .padding(10)
                    .background(Color.white.opacity(0.04))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            HStack {
                Text("Calories")
                    .foregroundStyle(.white)
                Spacer()
                Text("320")
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(8)
            .background(Color.white.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            HStack {
                Text("Servings")
                    .foregroundStyle(.white)
                Spacer()
                Text("1")
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(8)
            .background(Color.white.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            Toggle("High Protein", isOn: .constant(true))
                .tint(Color(red: 0.12, green: 0.95, blue: 0.72))

            Button(action: {}) {
                Text("Add Meal")
                    .font(.system(size: 15, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundStyle(.black)
                    .background(Color(red: 0.12, green: 0.95, blue: 0.72))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }
}

private struct FitTrackProgressScreen: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
                .padding(.top, 6)

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.12), lineWidth: 12)
                    .frame(width: 110, height: 110)
                Circle()
                    .trim(from: 0, to: 0.65)
                    .stroke(Color(red: 0.12, green: 0.95, blue: 0.72), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 110, height: 110)
                Text("65%")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)

            HStack(spacing: 8) {
                MiniStat(value: "4", label: "Workouts")
                MiniStat(value: "180", label: "Minutes")
                MiniStat(value: "5d", label: "Streak")
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Fitness Goal")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
                Picker("Goal", selection: .constant("Build Muscle")) {
                    Text("Build Muscle")
                }
                .pickerStyle(.menu)
                .padding(8)
                .background(Color.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }
}

private struct FitTrackProfileScreen: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(Color(red: 0.12, green: 0.95, blue: 0.72))
                    .frame(width: 42, height: 42)
                    .overlay(Text("R").foregroundStyle(.black).fontWeight(.bold))
                VStack(alignment: .leading) {
                    Text("Ruz")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Build Muscle")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                ProfileRow(label: "Personal Information")
                ProfileRow(label: "Nutrition Goals")
                ProfileRow(label: "Notifications")
                ProfileRow(label: "Log Out")
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }
}

private struct FitTrackSettingsScreen: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("App Notifications")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
                .padding(.top, 4)

            VStack(alignment: .leading, spacing: 8) {
                ToggleRow(label: "Workout Reminders", isOn: true)
                ToggleRow(label: "Meal Reminders", isOn: true)
                ToggleRow(label: "Progress Updates", isOn: true)
                ToggleRow(label: "Motivation Messages", isOn: false)
            }

            Button(action: {}) {
                Text("Reset Data")
                    .font(.system(size: 15, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundStyle(.white)
                    .background(Color.red.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }
}

private struct StatTile: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct MiniStat: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

private struct ProfileRow: View {
    let label: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(10)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

private struct ToggleRow: View {
    let label: String
    let isOn: Bool

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white)
            Spacer()
            Toggle("", isOn: .constant(isOn))
                .labelsHidden()
                .tint(Color(red: 0.12, green: 0.95, blue: 0.72))
        }
        .padding(10)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    ContentView()
}
