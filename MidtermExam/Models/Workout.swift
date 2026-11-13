import Foundation

struct WorkoutSession: Identifiable {
    let id = UUID()
    let title: String
    let duration: Int
    let focus: String
    let intensity: String
    let completed: Bool
}
