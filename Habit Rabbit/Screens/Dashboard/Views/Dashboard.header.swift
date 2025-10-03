import SwiftUI

extension Habit.Dashboard {
    
    @ViewBuilder
    var gridHeader: some View {
        if #unavailable(iOS 26.0) {
            VStack(spacing: 16) {
                modePicker
                lastDayControl
            }
            .padding(.vertical, 6)
            .padding(.bottom, 12)
            .animation(.bouncy, value: dashboardManager.lastDay)
        }
    }
    
    @ViewBuilder
    var emptyGridView: some View {
        if cardManagers.isEmpty {
            ContentUnavailableView(
                "No Habits",
                systemImage: "rectangle.portrait.slash.fill",
                description: Text("Create your first habit to get started!")
            )
        }
    }
    
}

extension Habit.Dashboard {
    
    private var modePicker: some View {
        ModePicker(
            width: 240,
            mode: dashboardManager.mode,
            onSelection: { mode in
                dashboardManager.updateMode(to: mode)
            }
        )
        .sensoryFeedback(.selection, trigger: dashboardManager.mode)
    }
    
}

extension Habit.Dashboard {
    
    var lastDayControl: some View {
        Text(dashboardManager.lastDay.formatted)
            .font(.system(size: 14, weight: .bold))
            .animation(.bouncy, value: dashboardManager.lastDay)
    }
    
    var lastDayToolbarControl: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            lastDayControl
        }
    }
    
    var previousDayToolbarButton: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                dashboardManager.shiftLastDay(to: .yesterday)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
            }
            .sensoryFeedback(.selection, trigger: dashboardManager.lastDay)
        }
    }
    
    var nextDayToolbarButton: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                dashboardManager.shiftLastDay(to: .tomorrow)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
            }
            .sensoryFeedback(.selection, trigger: dashboardManager.lastDay)
        }
    }
    
}
