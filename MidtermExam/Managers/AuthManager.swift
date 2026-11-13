import Foundation
import Combine
import SwiftUI
import SwiftData
import CryptoKit
import Security

@MainActor
final class AuthManager: ObservableObject {
    @Published var currentUser: UserModel?
    var isAuthenticated: Bool {
        currentUser != nil
    }

    private var modelContext: ModelContext?

    init() {
        currentUser = nil
    }

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
        restoreSession()
    }

    func register(
        fullName: String,
        username: String,
        email: String,
        password: String,
        confirmPassword: String
    ) -> String? {
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

        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let normalizedUser = username.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let context = modelContext else {
            return "Authentication context not available."
        }

        let descriptor = FetchDescriptor<UserModel>()
        let users = (try? context.fetch(descriptor)) ?? []

        if users.contains(where: { $0.email.lowercased() == normalizedEmail || $0.username.lowercased() == normalizedUser.lowercased() }) {
            return "An account with that email or username already exists."
        }

        let user = UserModel(
            fullName: fullName.trimmingCharacters(in: .whitespacesAndNewlines),
            username: normalizedUser,
            email: normalizedEmail,
            passwordHash: passwordHash(password),
            height: 0,
            weight: 0,
            fitnessGoal: "Build Muscle"
        )

        context.insert(user)
        do {
            try context.save()
        } catch {
            return "Unable to create your account right now."
        }

        currentUser = user
        persistSession(for: user)
        savePasswordHash(passwordHash(password), forUser: user.email)
        return nil
    }

    func login(emailOrUsername: String, password: String) -> String? {
        guard !emailOrUsername.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return "Email or username is required."
        }
        guard !password.isEmpty else {
            return "Password is required."
        }

        guard let context = modelContext else {
            return "Authentication context not available."
        }

        let query = FetchDescriptor<UserModel>()
        let users = (try? context.fetch(query)) ?? []

        let matchedUser = users.first {
            $0.email.lowercased() == emailOrUsername.lowercased() ||
            $0.username.lowercased() == emailOrUsername.lowercased()
        }

        guard let matchedUser else {
            return "No account found for that email or username."
        }

        let enteredHash = passwordHash(password)
        guard matchedUser.passwordHash == enteredHash else {
            return "Incorrect password."
        }

        currentUser = matchedUser
        persistSession(for: matchedUser)
        savePasswordHash(enteredHash, forUser: matchedUser.email)
        return nil
    }

    func logout() {
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: "fittrack.loggedInUserID")
    }

    func deleteCurrentUser() {
        guard let context = modelContext,
              let user = currentUser else { return }

        context.delete(user)
        try? context.save()
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: "fittrack.loggedInUserID")
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

    private func restoreSession() {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<UserModel>()
        let users = (try? context.fetch(descriptor)) ?? []
        let savedID = UserDefaults.standard.string(forKey: "fittrack.loggedInUserID")
        currentUser = users.first { $0.id.uuidString == savedID }
    }

    private func persistSession(for user: UserModel) {
        UserDefaults.standard.set(user.id.uuidString, forKey: "fittrack.loggedInUserID")
    }

    private func passwordHash(_ password: String) -> String {
        let input = Data(password.utf8)
        let digest = SHA256.hash(data: input)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private func savePasswordHash(_ hash: String, forUser email: String) {
        let key = "fittrack.password.\(email)"
        let data = Data(hash.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
}
