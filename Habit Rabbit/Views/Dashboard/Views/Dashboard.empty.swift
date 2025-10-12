import SwiftUI

extension Habit.Dashboard {
    
    @ViewBuilder
    var emptyView: some View {
        if cardManagers.isEmpty {
            ContentUnavailableView(
                "No Habits",
                systemImage: "rectangle.portrait.slash.fill",
                description: Text("Create your first habit to get started!")
            )
        }
    }
    
}
