import SwiftUI
import SwiftData

struct ProfileView: View {
    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.modelContext) private var context

    var body: some View {
        ZStack {
            LinearGradient(colors: [FitColors.background, Color(red: 0.05, green: 0.09, blue: 0.13)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Profile")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)

                    FitCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Circle()
                                    .fill(FitColors.primary)
                                    .frame(width: 52, height: 52)
                                    .overlay(Text(String((authManager.currentUser?.fullName.prefix(1) ?? "U")).uppercased()).fontWeight(.bold).foregroundStyle(.black))

                                VStack(alignment: .leading) {
                                    Text(authManager.currentUser?.fullName ?? "User")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundStyle(.white)
                                    Text(authManager.currentUser?.email ?? "")
                                        .font(.system(size: 12))
                                        .foregroundStyle(FitColors.textSecondary)
                                }
                            }
                        }
                    }

                    VStack(spacing: 12) {
                        NavigationLink(destination: EditProfileView()) {
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
                            authManager.deleteCurrentUser()
                        } label: {
                            ProfileRow(label: "Delete account", destructive: true)
                        }
                    }
                }
                .padding(20)
            }
        }
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
