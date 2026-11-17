import Foundation

@MainActor
final class SupabaseManager {
    static let shared = SupabaseManager()

    private init() {}

    var isConfigured: Bool {
        false
    }

    func configure() {
        // Add your Supabase URL + anon key here when you are ready.
        // Example:
        // SupabaseClient(supabaseURL: URL(string: "https://...supabase.co")!, supabaseKey: "...")
    }
}
