import SwiftUI
import SwiftData

extension Habit {
    // displays the value data of a habit for the time interval specified
    struct Card: View {
        @Environment(\.modelContext) var modelContext
        @Environment(\.colorScheme) var colorScheme
        @Namespace var modeTransition
        
        let manager: Habit.Card.Manager
        let mode: Habit.Card.Mode
        let index: Int
        let onDelete: () -> Void
        
        // card animates before being removed
        @State var isDeleting = false
        
        var body: some View {
            let _ = print("🔄 Card body evaluated: \(manager.habit.name)")
            
            VStack(spacing: 0) {
                // Content that should blur
                Group {
                    switch mode {
                        case .daily: dailyView
                        case .weekly: weeklyView
                        case .monthly: monthlyView
                    }
                }
                .transition(.blurReplace)
                
                VStack(spacing: mode == .monthly ? 4 : 2) {
                    habitLabel
                    if mode != .daily {
                        progressLabelCompact
                    }
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, labelBottomPadding)
            }
            .animation(.spring(duration: 0.62), value: mode)
            .frame(maxWidth: .infinity)
            .frame(height: 232)
            .background { background }
            .geometryGroup()
            .scaleEffect(isDeleting ? 0 : 1)
            .contentShape(.contextMenuPreview, .rect(cornerRadius: 24))
            .contextMenu { contextMenuButtons }
            .offset(isDeleting ? deleteOffset : .zero)
            .compositingGroup()
        }
        
        let contentHeight: CGFloat = 155
        
        var labelBottomPadding: CGFloat {
            switch mode {
                case .daily: 20
                case .weekly: 10
                case .monthly: 14
            }
        }
    }
}

extension Habit.Card {
    // properties for easy access to habit properties through viewModel
    var habit: Habit { manager.habit }
    var name: String { habit.name }
    var unit: String { habit.unit }
    var icon: String { habit.icon }
    var color: Color { habit.color }
    
    // value of the last day in the time interval
    var lastDayValue: Habit.Value? { manager.values.last }
    
    // values of the last 7 days of the time interval
    var weeklyValues: [Habit.Value] {
        let recentValues = manager.values.suffix(7)
        let weekDateRange = (0..<7).map { dayOffset in
            Calendar.current.date(byAdding: .day, value: -dayOffset, to: manager.lastDay)!
        }.reversed()
        
        let lookup = Dictionary(recentValues.map { ($0.date, $0) }, uniquingKeysWith: { first, _ in first })
        return weekDateRange.map { lookup[$0] ?? Habit.Value(habit: habit, date: $0, currentValue: 0) }
    }
    
    var displayValue: Int {
        switch habit.kind {
            case .good: currentValue
            case .bad: target - currentValue
        }
    }
    
    // cumulative value for the time interval
    var currentValue: Int {
        switch mode {
            case .daily: lastDayValue?.currentValue ?? 0
            case .weekly: weeklyValues.reduce(0) { $0 + $1.currentValue }
            case .monthly: manager.values.reduce(0) { $0 + $1.currentValue }
        }
    }
    
    // cumulative target, proportional to daily target
    var target: Int {
        switch mode {
            case .daily: habit.target
            case .weekly: habit.target * 7
            case .monthly: habit.target * 30
        }
    }
    
    // progress from 0 to 1
    var progress: CGFloat {
        guard target > 0 else { return 0 }
        return CGFloat(currentValue) / CGFloat(target)
    }
    
    // true if target has been reached
    var isCompleted: Bool {
        switch habit.kind {
            case .good: currentValue >= target
            case .bad: currentValue < target
        }
    }
}

extension Habit.Card {
    @ViewBuilder
    var contextMenuButtons: some View {
        Button("Weekly Values", systemImage: "7.circle.fill") {
            for value in weeklyValues {
                print("Value: \(value.currentValue)")
            }
        }
        Button("Randomize", systemImage: "sparkles") {
            manager.updateRandomValue()
        }
        Button("Reset", systemImage: "arrow.counterclockwise") {
            lastDayValue?.currentValue = 0
        }
        Button("Delete", systemImage: "trash", role: .destructive) {
            deleteWithAnimation()
        }
    }
}

extension Habit.Card {
    func deleteWithAnimation() {
        // animate card before deleting habit and all its values from context
        Task {
            try? await Task.sleep(nanoseconds: 10_000_000)
            withAnimation(.spring(duration: 0.8)) {
                isDeleting = true
            } completion: {
                isDeleting = false
            }
            
            try? await Task.sleep(nanoseconds: 10_000_000)
            modelContext.delete(habit)
            
            // here we need the parent to fetch and reconcile
            onDelete()
        }
    }
    
    var deleteOffset: CGSize {
        // cards animate towards nearest horizontal edge
        let offset = (index % 2 == 0) ? -250 : 250
        return CGSize(width: CGFloat(offset), height: 100)
    }
}

extension Habit.Card {
    // length of time interval habit card can display values for
    enum Mode: String, CaseIterable {
        case daily = "Daily" // current day
        case weekly = "Weekly" // last 7 days
        case monthly = "Monthly" // last 30 days
    }
}
