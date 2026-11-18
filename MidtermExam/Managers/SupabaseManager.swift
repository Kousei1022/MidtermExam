import Foundation

@MainActor
final class SupabaseManager {
    static let shared = SupabaseManager()

    private init() {}

    var isConfigured: Bool {
        false
    }

    func configure() {
    }
}
