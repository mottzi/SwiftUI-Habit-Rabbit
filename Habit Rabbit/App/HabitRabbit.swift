import SwiftUI
import SwiftData

@main
struct HabitRabbit: App {
    
    let container = try! ModelContainer(for: Habit.self, Habit.Value.self)
        
    var body: some Scene {
        let _ = print("root scene")
        
        WindowGroup {
            NavigationStack {
                Habit.Dashboard.Container()
            }
        }
        .modelContainer(container)
    }
    
}

extension Habit.Dashboard {
    
    struct Container: View {
        
        @Environment(\.modelContext) var modelContext
        
        var body: some View {
            let _ = print("container")
            let _ = Self._printChanges()
            
            Habit.Dashboard()
        }
        
    }
    
}
