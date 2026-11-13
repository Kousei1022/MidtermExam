import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Group {
            if authManager.isAuthenticated, let user = authManager.currentUser {
                MainTabView(currentUser: user)
            } else {
                SplashView()
            }
        }
        .onAppear {
            authManager.configure(modelContext: modelContext)
        }
    }
}
