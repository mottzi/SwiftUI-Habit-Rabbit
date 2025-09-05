import SwiftUI

extension Habit.Dashboard {
    
    var debugButton: some ToolbarContent {
        ToolbarItem {
            Menu {
                addExampleButton
                randomizeButton
                resetLatestButton
                Divider()
                zoomButton
                inlineButton
                Divider()
                killDatabaseButton
                deleteHabitsButton
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 34, height: 34)
                    .background { Habit.Card.Background(in: .circle).showShadows(false) }
            }
            .buttonStyle(.plain)
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
    
    var zoomButton: some View {
        Button(action: dashboardManager.toggleUseZoom) {
            Label("Zoom Transition", systemImage: useZoomSymbol)
        }
    }
    
    var inlineButton: some View {
        Button(action: dashboardManager.toggleUseInline) {
            Label("Inline Title", systemImage: useInlineSymbol)
        }
    }
    
    var useZoomSymbol: String {
        dashboardManager.useZoom ? "checkmark.circle.fill" : "circle"
    }
    
    var useInlineSymbol: String {
        dashboardManager.useInline ? "checkmark.circle.fill" : "circle"
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
