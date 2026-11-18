import Foundation
import Combine

@MainActor
final class WorkoutSessionStore: ObservableObject {
    @Published var sessionName = ""
    @Published var workoutDate = Date()
    @Published var exercises: [ExerciseDraft] = [ExerciseDraft()] {
        didSet { objectWillChange.send() }
    }
    @Published var timerSeconds = 0
    @Published var timerRunning = false
    @Published var restSeconds = 0
    @Published var restTimerRunning = false
    @Published var hasStarted = false
    @Published var selectedCategory = "All"
    @Published var searchText = ""
    @Published var elapsedSeconds = 0

    var isActive: Bool {
        hasStarted || !sessionName.isEmpty || exercises.contains { !$0.name.isEmpty || $0.sets.contains { $0.repetitions > 0 || $0.weight != "0" } }
    }

    func startNewSession() {
        sessionName = ""
        workoutDate = Date()
        exercises = [ExerciseDraft()]
        timerSeconds = 60 * 60
        elapsedSeconds = 0
        timerRunning = false
        restSeconds = 60
        restTimerRunning = false
        hasStarted = true
        selectedCategory = "All"
        searchText = ""
    }

    func clear() {
        sessionName = ""
        workoutDate = Date()
        exercises = [ExerciseDraft()]
        timerSeconds = 0
        timerRunning = false
        restSeconds = 0
        restTimerRunning = false
        hasStarted = false
        selectedCategory = "All"
        searchText = ""
    }
}
