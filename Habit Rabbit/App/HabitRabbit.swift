import SwiftUI
import SwiftData

@main
struct HabitRabbit: App {
    
    let container: ModelContainer
    
    @State var dashboardManager: Habit.Dashboard.Manager
        
    var body: some Scene {
        let _ = print("root scene")
        
        WindowGroup {
            NavigationStack {
                Habit.Dashboard(manager: dashboardManager)
            }
        }
        .modelContainer(container)
    }
    
    init() {
        container = try! ModelContainer(for: Habit.self, Habit.Value.self)
        
        print("App initializing ... ")
        let manager = Habit.Dashboard.Manager(using: container.mainContext)
        self._dashboardManager = State(initialValue: manager)
    }
    
}
