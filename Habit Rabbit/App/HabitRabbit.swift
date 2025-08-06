import SwiftUI
import SwiftData

@main
struct HabitRabbit: App {
    
    let container: ModelContainer
    
    @State var manager: Habit.Dashboard.Manager
        
    var body: some Scene {        
        WindowGroup {
            NavigationStack {
                Habit.Dashboard(manager: manager)
            }
        }
        .modelContainer(container)
    }
    
    init() {
        container = try! ModelContainer(for: Habit.self, Habit.Value.self)
        let manager = Habit.Dashboard.Manager(using: container.mainContext)
        self._manager = State(initialValue: manager)
    }
    
}
