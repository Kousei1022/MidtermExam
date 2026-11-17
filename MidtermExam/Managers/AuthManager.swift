import Foundation
import Combine
import SwiftUI
import SwiftData
import CryptoKit

@MainActor
final class AuthManager: ObservableObject {
    @Published var currentUser: UserModel?
    @Published private(set) var isFirebaseConfigured = false
    @Published private(set) var isSupabaseConfigured = false

    var isAuthenticated: Bool {
        currentUser != nil
    }

    private var modelContext: ModelContext?

    init() {
        currentUser = nil
    }

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
        isFirebaseConfigured = false
        isSupabaseConfigured = false
        restoreLocalSession()
    }

    func register(
        fullName: String,
        username: String,
        email: String,
        password: String,
        confirmPassword: String
    ) async -> String? {
        guard !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return "Full name is required."
        }
        guard !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return "Username is required."
        }
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return "Email is required."
        }
        guard password.count >= 6 else {
            return "Password must be at least 6 characters."
        }
        guard password == confirmPassword else {
            return "Passwords do not match."
        }

        guard let context = modelContext else {
            return "Local data is unavailable. Please reopen the app."
        }

        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let normalizedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let localUsers = (try? context.fetch(FetchDescriptor<UserModel>())) ?? []
        if localUsers.contains(where: {
            $0.email.lowercased() == normalizedEmail || $0.username.lowercased() == normalizedUsername.lowercased()
        }) {
            return "An account with that email or username already exists on this device."
        }

        let user = UserModel(
            fullName: fullName.trimmingCharacters(in: .whitespacesAndNewlines),
            username: normalizedUsername,
            email: normalizedEmail,
            passwordHash: passwordHash(password),
            firebaseUID: nil,
            fitnessGoal: "Build Muscle"
        )

        context.insert(user)
        do {
            try context.save()
            currentUser = user
            persistSession(for: user)
            return nil
        } catch {
            return "Unable to save the account locally."
        }
    }

    func login(emailOrUsername: String, password: String) async -> String? {
        let identifier = emailOrUsername.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !identifier.isEmpty else {
            return "Email is required."
        }
        guard !password.isEmpty else {
            return "Password is required."
        }

        guard let context = modelContext else {
            return "Local data is unavailable. Please reopen the app."
        }

        let normalizedIdentifier = identifier.lowercased()
        let localUsers = (try? context.fetch(FetchDescriptor<UserModel>())) ?? []
        let user = localUsers.first {
            $0.email.lowercased() == normalizedIdentifier || $0.username.lowercased() == normalizedIdentifier
        }

        guard let user else {
            return "No account found for this email or username."
        }

        guard user.passwordHash == passwordHash(password) else {
            return "Email or password is incorrect."
        }

        currentUser = user
        persistSession(for: user)
        return nil
    }

    func updateProfile(
        fullName: String,
        email: String,
        height: Double?,
        weight: Double?,
        fitnessGoal: String
    ) async -> String? {
        guard let context = modelContext, let user = currentUser else {
            return "Profile is not available."
        }

        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let previousWeight = user.weight

        user.fullName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        user.email = normalizedEmail
        if let height { user.height = height }
        if let weight { user.weight = weight }
        user.fitnessGoal = fitnessGoal

        if let weight, weight > 0, weight != previousWeight {
            let record = WeightRecordModel(user: user, weight: weight)
            context.insert(record)
        }

        do {
            try context.save()
            return nil
        } catch {
            return "Unable to save profile changes."
        }
    }

    func logout() {
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: "fittrack.loggedInUserID")
    }

    func deleteCurrentUser(password: String) async -> String? {
        guard let context = modelContext, let user = currentUser else { return nil }

        guard user.passwordHash == passwordHash(password) else {
            return "Password is incorrect."
        }

        context.delete(user)
        do {
            try context.save()
            logout()
            return nil
        } catch {
            return "Unable to delete the account."
        }
    }

    func currentUserFromContext() -> UserModel? {
        guard let context = modelContext else { return nil }
        let id = UserDefaults.standard.string(forKey: "fittrack.loggedInUserID")
        if let id, !id.isEmpty {
            let descriptor = FetchDescriptor<UserModel>(predicate: #Predicate { $0.id.uuidString == id })
            return try? context.fetch(descriptor).first
        }
        return nil
    }

    private func restoreLocalSession() {
        guard let context = modelContext else { return }
        let users = (try? context.fetch(FetchDescriptor<UserModel>())) ?? []
        let savedID = UserDefaults.standard.string(forKey: "fittrack.loggedInUserID")
        currentUser = users.first { $0.id.uuidString == savedID }
    }

    private func persistSession(for user: UserModel) {
        UserDefaults.standard.set(user.id.uuidString, forKey: "fittrack.loggedInUserID")
    }

    private func passwordHash(_ password: String) -> String {
        let digest = SHA256.hash(data: Data(password.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
