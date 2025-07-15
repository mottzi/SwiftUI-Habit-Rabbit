import SwiftUI
import SwiftData

@main
struct HabitRabbitApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                Habit.Dashboard()
                    .modelContainer(for: [Habit.self, Habit.Value.self])
            }
        }
    }
}
