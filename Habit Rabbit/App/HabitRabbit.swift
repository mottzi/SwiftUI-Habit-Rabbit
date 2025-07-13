import SwiftUI
import SwiftData
import AppData
import AppComponents

@main
struct HabitRabbitApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(day: .now)
                .modelContainer(for: [Habit.self, Habit.Value.self])
        }
    }
}

#Preview {
    ContentView(day: .now)
        .modelContainer(for: [Habit.self, Habit.Value.self])
}
