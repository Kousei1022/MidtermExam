import Foundation
import Combine
import SwiftUI
import SwiftData
import CryptoKit
import FirebaseAuth
import FirebaseCore

@MainActor
final class AuthManager: ObservableObject {
    @Published var currentUser: UserModel?
    @Published private(set) var isFirebaseConfigured = false

    var isAuthenticated: Bool {
        currentUser != nil
    }

    private var modelContext: ModelContext?

    init() {
        currentUser = nil
    }

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
        isFirebaseConfigured = FirebaseApp.app() != nil

        guard isFirebaseConfigured else {
            restoreLocalSession()
            return
        }

        guard let firebaseUser = Auth.auth().currentUser else {
            currentUser = nil
            UserDefaults.standard.removeObject(forKey: "fittrack.loggedInUserID")
            return
        }

        Task {
            await restoreFirebaseUser(firebaseUser)
        }
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
        guard isFirebaseConfigured, let context = modelContext else {
            return firebaseSetupMessage
        }

        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let normalizedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let localUsers = (try? context.fetch(FetchDescriptor<UserModel>())) ?? []
        if localUsers.contains(where: {
            $0.email.lowercased() == normalizedEmail || $0.username.lowercased() == normalizedUsername.lowercased()
        }) {
            return "An account with that email or username already exists on this device."
        }

        do {
            let credential = try await Auth.auth().createUser(withEmail: normalizedEmail, password: password)
            let user = UserModel(
                fullName: fullName.trimmingCharacters(in: .whitespacesAndNewlines),
                username: normalizedUsername,
                email: normalizedEmail,
                passwordHash: "",
                firebaseUID: credential.user.uid,
                fitnessGoal: "Build Muscle"
            )
            context.insert(user)
            try context.save()
            currentUser = user
            persistSession(for: user)

            do {
                try await FirebaseDataStore.shared.reserveUsername(normalizedUsername, uid: credential.user.uid)
                try await FirebaseDataStore.shared.saveProfile(user, uid: credential.user.uid)
            } catch {
                try? await FirebaseDataStore.shared.releaseUsername(normalizedUsername, uid: credential.user.uid)
                context.delete(user)
                try? context.save()
                try? await credential.user.delete()
                try? Auth.auth().signOut()
                currentUser = nil
                return authErrorMessage(error)
            }
            return nil
        } catch {
            return authErrorMessage(error)
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
        guard isFirebaseConfigured, let context = modelContext else {
            return firebaseSetupMessage
        }

        let normalizedIdentifier = identifier.lowercased()
        let localUsers = (try? context.fetch(FetchDescriptor<UserModel>())) ?? []
        let cachedUser = localUsers.first {
            $0.email.lowercased() == normalizedIdentifier || $0.username.lowercased() == normalizedIdentifier
        }
        let email = cachedUser?.email ?? normalizedIdentifier
        let shouldMigrateLocalData = cachedUser?.firebaseUID == nil
            && cachedUser?.passwordHash == passwordHash(password)

        if let cachedUser, shouldMigrateLocalData {
            do {
                let credential = try await Auth.auth().createUser(withEmail: email, password: password)
                cachedUser.firebaseUID = credential.user.uid
                currentUser = cachedUser
                persistSession(for: cachedUser)
                try context.save()
                do {
                    try await FirebaseDataStore.shared.reserveUsername(cachedUser.username, uid: credential.user.uid)
                    try await FirebaseDataStore.shared.uploadLocalData(for: cachedUser, uid: credential.user.uid, context: context)
                    return nil
                } catch {
                    try? await FirebaseDataStore.shared.releaseUsername(cachedUser.username, uid: credential.user.uid)
                    cachedUser.firebaseUID = nil
                    try? context.save()
                    try? await credential.user.delete()
                    try? Auth.auth().signOut()
                    currentUser = nil
                    UserDefaults.standard.removeObject(forKey: "fittrack.loggedInUserID")
                    return "Existing account migration failed: \(error.localizedDescription)"
                }
            } catch {
                // An existing Firebase account should use the normal sign-in path below.
            }
        }

        do {
            let credential = try await Auth.auth().signIn(withEmail: email, password: password)
            let firebaseUser = credential.user
            let cloudProfile = try await FirebaseDataStore.shared.loadProfile(uid: firebaseUser.uid)
            let user = cachedUser ?? UserModel(
                fullName: firebaseUser.displayName ?? "FitTrack Member",
                username: String(email.split(separator: "@").first ?? "member"),
                email: email,
                passwordHash: "",
                firebaseUID: firebaseUser.uid
            )
            user.firebaseUID = firebaseUser.uid
            if let cloudProfile {
                FirebaseDataStore.shared.applyProfile(cloudProfile, to: user, uid: firebaseUser.uid)
            } else {
                try await FirebaseDataStore.shared.saveProfile(user, uid: firebaseUser.uid)
            }
            if cachedUser == nil {
                context.insert(user)
            }
            try context.save()
            if shouldMigrateLocalData, let cachedUser {
                try await FirebaseDataStore.shared.reserveUsername(cachedUser.username, uid: firebaseUser.uid)
                try await FirebaseDataStore.shared.uploadLocalData(for: cachedUser, uid: firebaseUser.uid, context: context)
            }
            try await FirebaseDataStore.shared.syncToLocalCache(for: user, uid: firebaseUser.uid, context: context)
            currentUser = user
            persistSession(for: user)
            return nil
        } catch {
            if shouldMigrateLocalData, let cachedUser {
                cachedUser.firebaseUID = nil
                try? context.save()
            }
            try? Auth.auth().signOut()
            currentUser = nil
            UserDefaults.standard.removeObject(forKey: "fittrack.loggedInUserID")
            return authErrorMessage(error)
        }
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
        if normalizedEmail != user.email,
           let firebaseUser = Auth.auth().currentUser {
            do {
                try await firebaseUser.updateEmail(to: normalizedEmail)
            } catch {
                return authErrorMessage(error)
            }
        }

        user.fullName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        user.email = normalizedEmail
        if let height { user.height = height }
        if let weight { user.weight = weight }
        user.fitnessGoal = fitnessGoal

        if let weight, weight > 0, weight != previousWeight, let uid = user.firebaseUID {
            let record = WeightRecordModel(user: user, weight: weight)
            context.insert(record)
            do {
                try await FirebaseDataStore.shared.saveWeightRecord(record, uid: uid)
            } catch {
                return "Profile updated, but the weigh-in could not be synced to Firebase."
            }
        }

        do {
            try context.save()
            if let uid = user.firebaseUID {
                try await FirebaseDataStore.shared.saveProfile(user, uid: uid)
            }
            return nil
        } catch {
            return "Unable to save profile changes."
        }
    }

    func logout() {
        try? Auth.auth().signOut()
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: "fittrack.loggedInUserID")
    }

    func deleteCurrentUser(password: String) async -> String? {
        guard let context = modelContext, let user = currentUser else { return nil }

        if let uid = user.firebaseUID, let firebaseUser = Auth.auth().currentUser {
            do {
                guard let email = firebaseUser.email else {
                    return "This account cannot be reauthenticated for deletion."
                }
                let credential = EmailAuthProvider.credential(withEmail: email, password: password)
                try await firebaseUser.reauthenticate(with: credential)
                try await FirebaseDataStore.shared.deleteAccountData(uid: uid, username: user.username)
                try await firebaseUser.delete()
            } catch {
                return authErrorMessage(error)
            }
        }

        context.delete(user)
        try? context.save()
        logout()
        return nil
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

    private var firebaseSetupMessage: String {
        "Firebase is not configured yet. Add GoogleService-Info.plist to the MidtermExam app target."
    }

    private func restoreLocalSession() {
        guard let context = modelContext else { return }
        let users = (try? context.fetch(FetchDescriptor<UserModel>())) ?? []
        let savedID = UserDefaults.standard.string(forKey: "fittrack.loggedInUserID")
        currentUser = users.first { $0.id.uuidString == savedID }
    }

    private func restoreFirebaseUser(_ firebaseUser: FirebaseAuth.User) async {
        guard let context = modelContext else { return }
        do {
            let cloudProfile = try await FirebaseDataStore.shared.loadProfile(uid: firebaseUser.uid)
            let users = (try? context.fetch(FetchDescriptor<UserModel>())) ?? []
            let user = users.first { $0.firebaseUID == firebaseUser.uid }
                ?? users.first { $0.email.lowercased() == firebaseUser.email?.lowercased() }
                ?? UserModel(
                    fullName: firebaseUser.displayName ?? "FitTrack Member",
                    username: String((firebaseUser.email ?? "member@example.com").split(separator: "@").first ?? "member"),
                    email: firebaseUser.email ?? "",
                    passwordHash: "",
                    firebaseUID: firebaseUser.uid
                )
            user.firebaseUID = firebaseUser.uid
            if let cloudProfile {
                FirebaseDataStore.shared.applyProfile(cloudProfile, to: user, uid: firebaseUser.uid)
            } else {
                try await FirebaseDataStore.shared.saveProfile(user, uid: firebaseUser.uid)
            }
            if !users.contains(where: { $0.id == user.id }) {
                context.insert(user)
            }
            currentUser = user
            persistSession(for: user)
            try context.save()
            try await FirebaseDataStore.shared.syncToLocalCache(for: user, uid: firebaseUser.uid, context: context)
        } catch {
            currentUser = nil
        }
    }

    private func persistSession(for user: UserModel) {
        UserDefaults.standard.set(user.id.uuidString, forKey: "fittrack.loggedInUserID")
    }

    private func passwordHash(_ password: String) -> String {
        let digest = SHA256.hash(data: Data(password.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private func authErrorMessage(_ error: Error) -> String {
        let nsError = error as NSError
        if nsError.domain == AuthErrorDomain,
           let code = AuthErrorCode(rawValue: nsError.code) {
            switch code {
            case .emailAlreadyInUse:
                return "An account already exists for this email."
            case .invalidEmail:
                return "Enter a valid email address."
            case .weakPassword:
                return "Choose a stronger password with at least 6 characters."
            case .userNotFound, .wrongPassword, .invalidCredential:
                return "Email or password is incorrect."
            case .networkError:
                return "Unable to reach Firebase. Check your connection and try again."
            case .requiresRecentLogin:
                return "For security, sign out and sign back in before deleting your account."
            default:
                return error.localizedDescription
            }
        }
        return error.localizedDescription
    }
}
