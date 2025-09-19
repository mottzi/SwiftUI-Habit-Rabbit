import SwiftUI
import SwiftData

@main
struct HabitRabbit: App {
    
    let modelContainer: ModelContainer
    let dashboardManager: Habit.Dashboard.Manager 
    
    init() {
        modelContainer = try! ModelContainer(for: Habit.self, Habit.Value.self)
        dashboardManager = Habit.Dashboard.Manager(using: modelContainer.mainContext)
    }
    
    var body: some Scene {
        WindowGroup {
            Habit.Dashboard()
                .environment(dashboardManager)
        }
    }
    
}

#Preview {
    
    let modelContainer = try! ModelContainer(for: Habit.self, Habit.Value.self)
    let dashboardManager = Habit.Dashboard.Manager(using: modelContainer.mainContext)
    
    return Habit.Dashboard()
        .environment(dashboardManager)
        .modelContainer(modelContainer)
    
}
