import SwiftUI
import SwiftData
import AppComponents

@main
struct HabitRabbitApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(for: .now)
                .modelContainer(for: [Habit.self, HabitValue.self])
        }
    }
}

#Preview {
    ContentView(for: .now)
        .modelContainer(for: [Habit.self, HabitValue.self])
}
