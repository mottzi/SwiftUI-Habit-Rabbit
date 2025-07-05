import SwiftUI
import AppComponents

@main struct HabitRabbit: App
{
    var body: some Scene
    {
        WindowGroup
        {
            ContentView()
                .modelContainer(for: [Habit.self, HabitValue.self])
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Habit.self, HabitValue.self])
}
