import SwiftUI
import SwiftData

extension Habit.Card {
    @Observable
    class Manager {
        private let modelContext: ModelContext
        let habit: Habit
        let lastDay: Date
        
        var values: [Habit.Value] = []
        var mode: Habit.Card.Mode = .daily
        
        init(modelContext: ModelContext, habit: Habit, lastDay: Date) {
            self.modelContext = modelContext
            self.habit = habit
            self.lastDay = lastDay
            
            fetchValues()
        }
        
        // fetch the values of the last 30 days
        func fetchValues() {
            print(" ⬇ \(habit.name): fetching values")
            do {
                let description = Habit.Value.filterByDays(30, for: habit, endingOn: lastDay)
                values = try modelContext.fetch(description)                
            } catch {
                print("Failed to fetch values for \(habit.name):", error)
            }
        }
        
        // update mode and handle any mode-specific logic
        func updateMode(_ newMode: Habit.Card.Mode) {
            guard mode != newMode else { return }
            mode = newMode
        }
        
        // update the last fetched value
        func updateRandomValue() {
            if let value = values.last {
                value.currentValue = Int.random(in: 0...habit.target * 2)
            }
        }
    }
}

extension Habit.Card.Manager {
    // properties for easy access to habit properties through viewModel
    var kind: Habit.Kind { habit.kind }
    var name: String { habit.name }
    var unit: String { habit.unit }
    var icon: String { habit.icon }
    var color: Color { habit.color }
    
    // value of the last day in the time interval
    var lastDayValue: Habit.Value? { values.last }
    
    // values of the last 7 days of the time interval
    var weeklyValues: [Habit.Value] {
        let recentValues = values.suffix(7)
        let weekDateRange = (0..<7).map { dayOffset in
            Calendar.current.date(byAdding: .day, value: -dayOffset, to: lastDay)!
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
            case .monthly: values.reduce(0) { $0 + $1.currentValue }
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
