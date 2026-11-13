import SwiftUI
import SwiftData
import FirebaseCore
import UIKit

final class FitTrackAppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        guard Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist") != nil else {
            return true
        }
        FirebaseApp.configure()
        return true
    }
}

@main
struct MidtermExamApp: App {
    @UIApplicationDelegateAdaptor(FitTrackAppDelegate.self) private var appDelegate
    @StateObject private var authManager = AuthManager()
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(
                for: UserModel.self,
                WorkoutModel.self,
                MealModel.self,
                WeightRecordModel.self
            )
        } catch {
            fatalError("Failed to create model container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .modelContainer(modelContainer)
        }
    }
}
