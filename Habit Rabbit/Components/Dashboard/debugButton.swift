import SwiftUI

extension Habit.Dashboard {
    
    
    var debugButton: some View {
        Menu {
            addExampleButton
            randomizeButton
            resetAllButton
            Divider()
            removeDBButton
            removeHabitsButton
        } label: {
            HStack(spacing: 16) {
                Image(systemName: "hammer.fill")
                    .foregroundStyle(colorScheme == .light ? .black : .white)
                    .frame(width: 64, height: 64)
                    .background(Circle().fill(.quaternary))
                    .padding()
                
                Text("Habits: \(dashboardManager.cardManagers.count)")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary.opacity(0.7))
            }
        }
        .buttonStyle(.plain)
    }
    
}

extension Habit.Dashboard {
    
    private var addExampleButton: some View {
        Menu {
            ForEach([1, 2, 4, 8, 20, 50, 100], id: \.self) { count in
                Button("\(count)") {
                    try? dashboardManager.addExampleHabits(count: count)
                }
            }
        } label: {
            Label("Add Examples", systemImage: "plus")
        }
    }
    
    private var randomizeButton: some View {
        Button("Randomize All", systemImage: "sparkles") {
            dashboardManager.randomizeAllHabits()
        }
    }
    
    private var resetAllButton: some View {
        Button("Reset All", systemImage: "0.circle") {
            dashboardManager.resetAllHabits()
        }
    }
    
    private var removeDBButton: some View {
        Button("Kill Database", systemImage: "xmark", role: .destructive) {
            dashboardManager.deleteAllData()
        }
    }
    
    private var removeHabitsButton: some View {
        Button("Delete All", systemImage: "trash", role: .destructive) {
            try? dashboardManager.deleteAllHabits()
        }
    }
    
}
