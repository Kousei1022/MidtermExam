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

import Supabase

final class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: "https://vufsotdzytnnrhnjfdip.supabase.co")!,
            supabaseKey: "sb_publishable_N215QYsClJ_0LsnHqFcc6g_2FLcvxZR"
        )
    }
}