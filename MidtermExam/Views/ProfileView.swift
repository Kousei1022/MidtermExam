import SwiftUI
import SwiftData

struct ProfileView: View {
    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.modelContext) private var context
    @Query(sort: \WorkoutModel.date, order: .reverse) private var allWorkouts: [WorkoutModel]
    @State private var deleteAccountError: String?
    @State private var isShowingDeleteSheet = false

    private var user: UserModel? {
        authManager.currentUser
    }

    private var workouts: [WorkoutModel] {
        guard let user else { return [] }
        return allWorkouts.filter { $0.user?.id == user.id }
    }

    private var workoutsThisWeek: Int {
        guard let week = Calendar.current.dateInterval(of: .weekOfYear, for: Date()) else { return 0 }
        return workouts.filter { week.contains($0.date) }.count
    }

    private var totalMinutes: Int {
        workouts.reduce(0) { $0 + $1.duration }
    }

    private var profileCompletion: Double {
        guard let user else { return 0 }
        let completedFields = [
            !user.fullName.isEmpty,
            !user.email.isEmpty,
            user.height > 0,
            user.weight > 0,
            !user.fitnessGoal.isEmpty
        ].filter { $0 }.count
        return Double(completedFields) / 5
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [FitColors.background, Color(red: 0.05, green: 0.09, blue: 0.13)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Profile")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)

                    if let user {
                        FitCard {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(spacing: 14) {
                                    Circle()
                                        .fill(FitColors.primary)
                                        .frame(width: 58, height: 58)
                                        .overlay {
                                            Text(String(user.fullName.prefix(1)).uppercased())
                                                .font(.system(size: 22, weight: .bold))
                                                .foregroundStyle(.black)
                                        }

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(user.fullName)
                                            .font(.system(size: 19, weight: .bold))
                                            .foregroundStyle(.white)
                                        Text("@\(user.username)")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundStyle(FitColors.textSecondary)
                                        Text(user.email)
                                            .font(.system(size: 12))
                                            .foregroundStyle(FitColors.textSecondary)
                                    }
                                    Spacer(minLength: 0)
                                }

                                Divider().overlay(Color.white.opacity(0.12))

                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Profile details")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundStyle(.white)
                                        Spacer()
                                        Text("\(Int(profileCompletion * 100))%")
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundStyle(FitColors.primary)
                                    }
                                    ProgressView(value: profileCompletion)
                                        .tint(FitColors.primary)
                                    Text(profileCompletion < 1 ? "Add your height and weight to complete your profile." : "Your profile details are complete.")
                                        .font(.system(size: 12))
                                        .foregroundStyle(FitColors.textSecondary)
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Training summary")
                                .font(.system(size: 19, weight: .bold))
                                .foregroundStyle(.white)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                ProfileMetric(value: "\(workoutsThisWeek)", label: "This week", icon: "calendar")
                                ProfileMetric(value: "\(workouts.count)", label: "Total workouts", icon: "dumbbell.fill")
                                ProfileMetric(value: "\(totalMinutes / 60)h \(totalMinutes % 60)m", label: "Time trained", icon: "clock.fill")
                                ProfileMetric(value: "\(workouts.filter(\.isCompleted).count)", label: "Completed", icon: "checkmark.circle.fill")
                            }
                        }

                        FitCard {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    Text("Your details")
                                        .font(.system(size: 17, weight: .bold))
                                        .foregroundStyle(.white)
                                    Spacer()
                                    NavigationLink(destination: EditProfileView(user: user)) {
                                        Label("Edit", systemImage: "pencil")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundStyle(FitColors.primary)
                                    }
                                }

                                ProfileInfoRow(label: "Fitness goal", value: user.fitnessGoal, icon: "scope")
                                ProfileInfoRow(label: "Height", value: user.height > 0 ? "\(user.height.formatted()) cm" : "Not set", icon: "ruler")
                                ProfileInfoRow(label: "Weight", value: user.weight > 0 ? "\(user.weight.formatted()) kg" : "Not set", icon: "scalemass")
                                ProfileInfoRow(label: "Member since", value: user.createdAt.formatted(date: .abbreviated, time: .omitted), icon: "calendar")
                            }
                        }

                        VStack(spacing: 12) {
                            NavigationLink(destination: EditProfileView(user: user)) {
                                ProfileRow(label: "Edit profile")
                            }
                            NavigationLink(destination: NotificationView()) {
                                ProfileRow(label: "Notifications")
                            }
                            Button {
                                authManager.logout()
                            } label: {
                                ProfileRow(label: "Log out")
                            }
                            Button {
                                isShowingDeleteSheet = true
                            } label: {
                                ProfileRow(label: "Delete account", destructive: true)
                            }
                        }
                    } else {
                        Text("Sign in to view your profile and training summary.")
                            .foregroundStyle(FitColors.textSecondary)
                    }
                }
                .padding(20)
            }
        }
        .alert("Unable to delete account", isPresented: Binding(
            get: { deleteAccountError != nil },
            set: { if !$0 { deleteAccountError = nil } }
        )) {
            Button("OK", role: .cancel) { deleteAccountError = nil }
        } message: {
            Text(deleteAccountError ?? "Please try again.")
        }
        .sheet(isPresented: $isShowingDeleteSheet) {
            DeleteAccountSheet { password in
                let result = await authManager.deleteCurrentUser(password: password)
                if let result {
                    deleteAccountError = result
                }
                return result
            }
            .presentationDetents([.medium])
        }
    }
}

private struct DeleteAccountSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isDeleting = false

    let onDelete: (String) async -> String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Delete account")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
            Text("This permanently removes your profile and saved fitness data. Confirm your password to continue.")
                .font(.system(size: 14))
                .foregroundStyle(FitColors.textSecondary)

            SecureField("Password", text: $password)
                .padding(12)
                .background(Color(red: 0.96, green: 0.97, blue: 0.99))
                .foregroundStyle(.black)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            if let errorMessage {
                Text(errorMessage)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(FitColors.danger)
            }

            HStack(spacing: 10) {
                Button("Cancel") { dismiss() }
                    .frame(maxWidth: .infinity, minHeight: 46)
                    .foregroundStyle(.white)
                    .background(FitColors.panelAlt)
                    .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))

                Button(isDeleting ? "Deleting..." : "Delete account", role: .destructive) {
                    Task { await deleteAccount() }
                }
                .disabled(isDeleting || password.isEmpty)
                .frame(maxWidth: .infinity, minHeight: 46)
                .foregroundStyle(.white)
                .background(FitColors.danger)
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(FitColors.background.ignoresSafeArea())
    }

    private func deleteAccount() async {
        guard !isDeleting else { return }
        isDeleting = true
        defer { isDeleting = false }
        if let message = await onDelete(password) {
            errorMessage = message
        } else {
            dismiss()
        }
    }
}

private struct ProfileMetric: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(FitColors.primary)
                .frame(width: 34, height: 34)
                .background(FitColors.primary.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(FitColors.textSecondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(FitColors.panel)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct ProfileInfoRow: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(FitColors.secondary)
                .frame(width: 20)
            Text(label)
                .foregroundStyle(FitColors.textSecondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .multilineTextAlignment(.trailing)
        }
        .font(.system(size: 13))
    }
}

private struct ProfileRow: View {
    let label: String
    var destructive: Bool = false

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(destructive ? FitColors.danger : .white)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(destructive ? FitColors.danger : FitColors.textSecondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthManager())
}
