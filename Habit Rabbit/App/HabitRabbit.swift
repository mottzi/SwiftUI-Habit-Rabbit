import SwiftUI
import SwiftData

@main
struct HabitRabbitApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
                    .modelContainer(for: [Habit.self, Habit.Value.self])
            }
        }
    }
}
