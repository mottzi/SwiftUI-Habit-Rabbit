import SwiftUI

extension Habit.Dashboard {
    
    var debugButton: some View {
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
            Image(systemName: "hammer.fill")
                .foregroundStyle(colorScheme == .light ? .black : .white)
                .frame(width: 64, height: 64)
                .background { Habit.Card.Background(in: .circle) }
                .padding()
        }
        .buttonStyle(.plain)
        .offset(x: 12, y: 12)
    }
    
}

extension Habit.Dashboard {
    
    private var addExampleButton: some View {
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
    
    private var randomizeButton: some View {
        Button("Randomize All", systemImage: "sparkles") {
            dashboardManager.randomizeAllHabits()
        }
    }
    
    private var resetLatestButton: some View {
        Button("Reset Latest", systemImage: "0.circle") {
            dashboardManager.resetLatestHabits()
        }
    }
    
}

extension Habit.Dashboard {
    
    private var zoomButton: some View {
        Button(action: dashboardManager.toggleUseZoom) {
            Label("Zoom Transition", systemImage: useZoomSymbol)
        }
    }
    
    private var inlineButton: some View {
        Button(action: dashboardManager.toggleUseInline) {
            Label("Inline Title", systemImage: useInlineSymbol)
        }
    }
    
    private var useZoomSymbol: String {
        dashboardManager.useZoom ? "checkmark.circle.fill" : "circle"
    }
    
    private var useInlineSymbol: String {
        dashboardManager.useInline ? "checkmark.circle.fill" : "circle"
    }
    
}

extension Habit.Dashboard {
    
    private var killDatabaseButton: some View {
        Button("Kill Database", systemImage: "xmark", role: .destructive) {
            dashboardManager.deleteAllData()
        }
    }
    
    private var deleteHabitsButton: some View {
        Button("Delete All", systemImage: "trash", role: .destructive) {
            try? dashboardManager.deleteAllHabits()
        }
    }
    
}
