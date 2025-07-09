import SwiftUI
import SwiftData
import AppData
import AppComponents

@main
struct HabitRabbitApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(day: .now)
                .modelContainer(for: [Habit.self, HabitValue.self])
        }
    }
}

#Preview {
    ContentView(day: .now)
        .modelContainer(for: [Habit.self, HabitValue.self])
}
