import SwiftUI
import SwiftData

@main
struct HabitRabbit: App {
    
    let container = try! ModelContainer(for: Habit.self, Habit.Value.self)
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                Habit.Dashboard(using: container.mainContext)
            }
        }
        .modelContainer(container)
    }
    
}
