import SwiftUI

extension Habit.Dashboard {
    
    var debugButton: some View {
        Menu {
            adjustLastDayButton
            Divider()
            addExampleButton
            randomizeButton
            resetAllButton
            Divider()
            zoomTransitionButton
            Divider()
            removeDBButton
            removeHabitsButton
        } label: {
            HStack(spacing: 16) {
                Image(systemName: "hammer.fill")
                    .foregroundStyle(colorScheme == .light ? .black : .white)
                    .frame(width: 64, height: 64)
                    .background { Habit.Card.Background(in: .circle) }
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
    
    private var adjustLastDayButton: some View {
        Menu {
            Button("Back") { dashboardManager.shiftDay(to: .yesterday) }
            Button("Forward") { dashboardManager.shiftDay(to: .tomorrow) }
        } label: {
            Label("Last Day", systemImage: "calendar")
        }
    }
    
    private var addExampleButton: some View {
        Menu {
            ForEach([1, 2, 4, 8, 20, 50, 100], id: \.self) { count in
                Button("\(count)") {
                    dashboardManager.addExampleHabits(count: count)
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
    
    private var zoomTransitionButton: some View {
        Button(action: dashboardManager.toggleZoomTransition) {
            Label("Zoom Transition", systemImage: zoomTransitionSymbol)
        }
    }
    
    private var zoomTransitionSymbol: String {
        dashboardManager.useZoomTransition ? "checkmark.circle.fill" : "circle"
    }
    
}
