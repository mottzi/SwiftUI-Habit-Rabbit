import SwiftUI
import SwiftData

@main
struct HabitRabbit: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
        }
        .modelContainer(for: [Habit.self, Habit.Value.self])
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        Habit.Dashboard.Container(using: modelContext)
    }
}

extension Habit.Dashboard {
    struct Container: View {
        @State private var manager: Habit.Dashboard.Manager
        
        init(using modelContext: ModelContext) {
            self._manager = State(initialValue: Habit.Dashboard.Manager(modelContext: modelContext))
        }
        
        var body: some View {
            Habit.Dashboard(manager: manager)
        }
    }
}

