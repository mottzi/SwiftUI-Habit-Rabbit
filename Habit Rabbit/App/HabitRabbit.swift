import SwiftUI
import SwiftData

@main
struct HabitRabbit: App {
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                Habit.Dashboard.Container()
            }
        }
        .modelContainer(for: [Habit.self, Habit.Value.self])
    }
    
}

extension Habit.Dashboard {
    
    struct Container: View {
        @Environment(\.modelContext) private var modelContext
        
        var body: some View {
            Habit.Dashboard(using: modelContext)
        }
    }
    
}
