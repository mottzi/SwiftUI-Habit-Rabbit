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
        HStack(spacing: 16) {
            previousDayButton
            Text(dashboardManager.lastDay.formatted)
                .font(.system(size: 14, weight: .bold))
                .animation(.bouncy, value: dashboardManager.lastDay)
            nextDayButton
        }
    }
    
    private var previousDayButton: some View {
        Button {
            dashboardManager.shiftLastDay(to: .yesterday)
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 34, height: 34)
                .background { Habit.Card.Background(in: .circle).showShadows(false) }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: dashboardManager.lastDay)
    }
    
    private var nextDayButton: some View {
        Button {
            dashboardManager.shiftLastDay(to: .tomorrow)
        } label: {
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 34, height: 34)
                .background { Habit.Card.Background(in: .circle).showShadows(false) }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: dashboardManager.lastDay)
    }
    
}
