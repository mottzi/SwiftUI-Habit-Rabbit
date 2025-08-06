import SwiftUI
import SwiftData

@main
struct HabitRabbit: App {
    
    let modelContainer: ModelContainer
    let dashboardManager: Habit.Dashboard.Manager
        
    var body: some Scene {        
        WindowGroup {
            NavigationStack {
                Habit.Dashboard()
                    .environment(dashboardManager)
            }
        }
    }
    
    init() {
        modelContainer = try! ModelContainer(for: Habit.self, Habit.Value.self)
        dashboardManager = Habit.Dashboard.Manager(using: modelContainer.mainContext)
    }
    
}
