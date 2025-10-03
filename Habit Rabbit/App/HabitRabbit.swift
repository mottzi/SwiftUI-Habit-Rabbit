import SwiftUI
import SwiftData

@main
struct HabitRabbit: App {
    
    let modelContainer: ModelContainer
    let dashboardManager: Habit.Dashboard.Manager 
    
    init() {
        modelContainer = try! ModelContainer(for: Habit.self, Habit.Value.self)
        dashboardManager = Habit.Dashboard.Manager(using: modelContainer.mainContext)
        
        let appearance = UISegmentedControl.appearance()
        appearance.setTitleTextAttributes([
            .font: UIFont.boldSystemFont(ofSize: 14)
        ], for: .selected)
        
        appearance.setTitleTextAttributes([
            .font: UIFont.boldSystemFont(ofSize: 14)
        ], for: .normal)
    }
    
    var body: some Scene {
        WindowGroup {
            Habit.Dashboard()
                .environment(dashboardManager)
        }
    }
    
}

@MainActor
var habitRabitPreview: some View {
    let modelContainer = try! ModelContainer(for: Habit.self, Habit.Value.self)
    let dashboardManager = Habit.Dashboard.Manager(using: modelContainer.mainContext)
    
    return Habit.Dashboard()
        .environment(dashboardManager)
        .modelContainer(modelContainer)
}

#Preview { habitRabitPreview }
