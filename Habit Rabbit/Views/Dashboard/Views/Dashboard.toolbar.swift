import SwiftUI

extension Habit.Dashboard {
    
    @ToolbarContentBuilder
    var toolbar: some ToolbarContent {
        toolbarTitle
        #if DEBUG
        toolbarDebugButton
        #endif
        toolbarAddHabitButton
    }
    
}

extension Habit.Dashboard {
    
    var toolbarTitle: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            VStack(alignment: .leading, spacing: -1) {
                Text(verbatim: "Habit Rabbit")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text(verbatim: dashboardManager.lastDay.formatted(.weekdayDate))
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 12)
            .padding(.leading, 4)
        }
    }
    
}

extension Habit.Dashboard {
    
    var toolbarDebugButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu("Debug", systemImage: "gear") {
                addExampleButton
                randomizeButton
                resetLatestButton
                Divider()
                killDatabaseButton
                deleteHabitsButton
            }
        }
    }
    
}

extension Habit.Dashboard {
    
    var addExampleButton: some View {
        Menu("Add Examples", systemImage: "plus") {
            ForEach([1, 2, 4, 8, 20, 50, 100], id: \.self) { count in
                Button(String("\(count)")) {
                    dashboardManager.addExampleHabits(count: count)
                }
            }
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

extension Habit.Dashboard {
    
    var toolbarAddHabitButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Add Habit", systemImage: "plus") {
                showAddSheet = true
            }
        }
    }
    
}
