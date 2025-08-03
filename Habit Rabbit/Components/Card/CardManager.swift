import SwiftUI
import SwiftData

extension Habit.Card {
    
    @Observable
    class Manager {
        
        private(set) var values: [Habit.Value] = []
        private(set) var mode: Habit.Card.Mode
        
        let habit: Habit
        let lastDay: Date
        let modelContext: ModelContext
        
        let contentHeight: CGFloat = 155

        init(
            for habit: Habit,
            until lastDay: Date,
            mode: Habit.Card.Mode,
            using modelContext: ModelContext,
        ) {
            self.habit = habit
            self.mode = mode
            self.lastDay = lastDay
            self.modelContext = modelContext
            
            fetchValues()
        }
        
        func fetchValues() {
            print("    ⬇ fetching values")
            do {
                let description = Habit.Value.filterByDays(30, for: habit, endingOn: lastDay)
                values = try modelContext.fetch(description)
            } catch {
                print("Failed to fetch values for \(habit.name):", error)
            }
        }
        
        func updateMode(to newMode: Habit.Card.Mode) {
            if mode != newMode { mode = newMode }
        }
        
        // update the last fetched value
        func randomizeLastDayValue() {
            lastDayValue?.currentValue = Int.random(in: 0...habit.target * 2)
        }
        
        func resetLastDayValue() {
            lastDayValue?.currentValue = 0
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
        let firstDay = Calendar.current.date(byAdding: .day, value: -6, to: lastDay)!
        let allDays = (0..<7).map {
            Calendar.current.date(byAdding: .day, value: $0, to: firstDay)!
        }
                
        let lookup = Dictionary(values.suffix(7).map { ($0.date, $0) }, uniquingKeysWith: { _, latest in latest })
        
        return allDays.map { day in
            lookup[day] ?? Habit.Value(habit: habit, date: day, currentValue: 0)
        }
    }
    
    // 5x7 grid with today at bottom-right
    var monthlyValues: [[Habit.Value?]] {
        let totalCells = 5 * 7
        let paddingCount = totalCells - values.count
        
        var paddedValues: [Habit.Value?] = Array(repeating: nil, count: paddingCount)
        paddedValues.append(contentsOf: values.map { $0 as Habit.Value? })
        
        // Convert flat array to 5x7 grid
        return stride(from: 0, to: paddedValues.count, by: 7).map { startIndex in
            Array(paddedValues[startIndex..<min(startIndex + 7, paddedValues.count)])
        }
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
    
    var labelBottomPadding: CGFloat {
        switch mode {
            case .daily: 20
            case .weekly: 10
            case .monthly: 14
        }
    }
    
}
