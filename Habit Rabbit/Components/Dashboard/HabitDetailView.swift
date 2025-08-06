
import SwiftUI

struct HabitDetailView: View {
    
    @Environment(Habit.Dashboard.Manager.self) var dashboardManager
    @Environment(Habit.Card.Manager.self) var cardManager
    
    var body: some View {
        Habit.Card()
            .environment(dashboardManager)
            .environment(cardManager)
            .containerRelativeFrame(.horizontal, count: 2, spacing: 16)        
    }
    
}
