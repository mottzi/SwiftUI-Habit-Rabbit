import SwiftUI

extension Habit.Dashboard {
    
    var gridHeader: some View {
        VStack(spacing: 16) {
            modePicker
            dateView
        }
        .padding(.vertical, 6)
        .animation(.bouncy, value: dashboardManager.lastDay)
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
    
    private var dateView: some View {
        HStack(spacing: 16) {
            previousDayButton
            Text(dashboardManager.lastDay.formatted)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
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
                .background { Habit.Card.Background(in: .circle) }
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
                .background { Habit.Card.Background(in: .circle) }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: dashboardManager.lastDay)
    }
    
}
