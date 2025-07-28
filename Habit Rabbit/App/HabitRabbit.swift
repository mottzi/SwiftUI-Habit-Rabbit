import SwiftUI
import SwiftData

@main
struct HabitRabbit: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                //                TestDashboard(lastDay: .now.startOfDay)
                Habit.Dashboard()
            }
        }
        .modelContainer(for: [Habit.self, Habit.Value.self])
    }
}
