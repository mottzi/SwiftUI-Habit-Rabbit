import SwiftUI
import SwiftData

@main
struct HabitRabbit: App {
    
    let container = try! ModelContainer(for: Habit.self, Habit.Value.self)
        
    var body: some Scene {
        let _ = print("root scene")
        
        WindowGroup {
            NavigationStack {
                Habit.Dashboard(modelContext: container.mainContext)
            }
        }
        .modelContainer(container)
    }
    
}
