import SwiftUI
import SwiftData

@main
struct HabitRabbit: App {
    
    let modelContainer: ModelContainer
    let dashboardManager: Habit.Dashboard.Manager
    
    var body: some Scene {
        WindowGroup {
            Habit.Dashboard()
                .environment(dashboardManager)
                .fontDesign(.rounded)
        }
    }
    
    init() {
        modelContainer = try! ModelContainer(for: Habit.self, Habit.Value.self)
        dashboardManager = Habit.Dashboard.Manager(using: modelContainer.mainContext)
    }
    
}
