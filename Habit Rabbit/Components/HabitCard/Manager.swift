import SwiftUI
import SwiftData

extension Habit.Card {
    @Observable
    class Manager {
        private let modelContext: ModelContext
        private let lastDay: Date

        let habit: Habit
        var values: [Habit.Value] = []
        var mode: Habit.Card.Mode
        
        init(
            for habit: Habit,
            until lastDay: Date,
            mode: Habit.Card.Mode,
            in modelContext: ModelContext,
        ) {
            self.modelContext = modelContext
            self.habit = habit
            self.lastDay = lastDay
            self.mode = mode
            
            fetchValues()
        }
        
        // fetch the values of the last 30 days
        func fetchValues() {
            print("    ⬇ fetching values")
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
        func randomizeLastDayValue() {
            lastDayValue?.currentValue = Int.random(in: 0...habit.target * 2)
        }
        
        // create and randomize 30 days of values for this habit
        func createRandomizedHistory() {
            let calendar = Calendar.current
            
            // create lookup of existing values by date
            let existingValues = Dictionary(values.map { ($0.date, $0) }, uniquingKeysWith: { first, _ in first })
            
            // create or update 30 days of random values
            for dayOffset in 0..<30 {
                let date = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -dayOffset, to: lastDay)!)
                let randomValue = Int.random(in: 0...habit.target * 2)
                
                if let existingValue = existingValues[date] {
                    // update existing value
                    existingValue.currentValue = randomValue
                } else {
                    // create new value
                    let value = Habit.Value(habit: habit, date: date, currentValue: randomValue)
                    modelContext.insert(value)
                }
            }
            
            // refresh this manager's values to include the new data
            fetchValues()
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
