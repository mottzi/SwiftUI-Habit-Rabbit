import SwiftUI

extension Habit.Dashboard {
    
    var debugToolbarButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                addExampleButton
                randomizeButton
                resetLatestButton
                Divider()
                killDatabaseButton
                deleteHabitsButton
            } label: {
                Label("Debug", systemImage: "gear")
            }
        }
    }
    
}

extension Habit.Dashboard {
    
    var addExampleButton: some View {
        Menu {
            ForEach([1, 2, 4, 8, 20, 50, 100], id: \.self) { count in
                Button(String("\(count)")) {
                    dashboardManager.addExampleHabits(count: count)
                }
            }
        } label: {
            Label("Add Examples", systemImage: "plus")
        }
    }
    
    var randomizeButton: some View {
        Button("Randomize All", systemImage: "sparkles") {
            dashboardManager.randomizeAllHabits()
        }
    }
    
    var resetLatestButton: some View {
        Button("Reset Latest", systemImage: "0.circle") {
            dashboardManager.resetLatestHabits()
        }
    }
    
}

extension Habit.Dashboard {
    
    var killDatabaseButton: some View {
        Button("Kill Database", systemImage: "xmark", role: .destructive) {
            dashboardManager.deleteAllData()
        }
    }
    
    var deleteHabitsButton: some View {
        Button("Delete All", systemImage: "trash", role: .destructive) {
            try? dashboardManager.deleteAllHabits()
        }
    }
    
}
