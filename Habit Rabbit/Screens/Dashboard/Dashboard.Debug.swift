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
            inlineNavTitleButton
            Divider()
            removeDBButton
            removeHabitsButton
        } label: {
            Image(systemName: "hammer.fill")
                .foregroundStyle(colorScheme == .light ? .black : .white)
                .frame(width: 64, height: 64)
                .background { Habit.Card.Background(in: .circle) }
                .padding()
        }
        .buttonStyle(.plain)
    }
    
}

extension Habit.Dashboard {
    
    private var adjustLastDayButton: some View {
        Menu {
            Button("Back") { dashboardManager.shiftLastDay(to: .yesterday) }
            Button("Forward") { dashboardManager.shiftLastDay(to: .tomorrow) }
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
    
    private var inlineNavTitleButton: some View {
        Button(action: dashboardManager.toggleInlineNavTitle) {
            Label("Inline Title", systemImage: inlineNavTitleSymbol)
        }
    }
    
    private var zoomTransitionSymbol: String {
        dashboardManager.useZoom ? "checkmark.circle.fill" : "circle"
    }
    
    private var inlineNavTitleSymbol: String {
        dashboardManager.useInline ? "checkmark.circle.fill" : "circle"
    }
    
}
