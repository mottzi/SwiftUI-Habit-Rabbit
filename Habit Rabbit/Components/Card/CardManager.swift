import SwiftUI
import SwiftData

extension Habit.Card {
    
    @Observable
    class Manager {

        private var values: [Habit.Value] = []
        private(set) var mode: Habit.Card.Mode
        
//        @ObservationIgnored
        let habit: Habit
        private let lastDay: Date
        let modelContext: ModelContext
                
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
        
        var name: String { habit.name }
        var unit: String { habit.unit }
        var icon: String { habit.icon }
        var color: Color { habit.color }
        var target: Int { habit.target }
        var kind: Habit.Kind { habit.kind }
        
    }
    
}

extension Habit.Card.Manager {
        
    private func fetchValues() {
        print("    ⬇ fetching values")
        let description = Habit.Value.filterByDays(30, for: habit, endingOn: lastDay)
        guard let newValues = try? modelContext.fetch(description) else { return }
        values = newValues
    }
    
    func updateMode(to newMode: Habit.Card.Mode) {
        if mode != newMode { mode = newMode }
    }
    
    func resetDailyValue() {
        dailyValue?.currentValue = 0
    }
    
    func randomizeDailyValue() {
        dailyValue?.currentValue = Int.random(in: 0...habit.target * 2)
    }
    
    func randomizeName() {
        print("randomizing name of \(habit.name)")
        habit.name = "Test \(Int.random(in: 1...1000))"
        
    }
    
    func randomizeMonthlyValues() {
        let existingValues = Dictionary(values.map { ($0.date, $0) }, uniquingKeysWith: { first, _ in first })
        
        for dayOffset in 0..<30 {
            let date = Calendar.current.date(byAdding: .day, value: -dayOffset, to: lastDay)!.startOfDay
            let randomValue = Int.random(in: 0...habit.target * 2)
            
            if let existingValue = existingValues[date] {
                existingValue.currentValue = randomValue
            } else {
                let value = Habit.Value(habit: habit, date: date, currentValue: randomValue)
                modelContext.insert(value)
            }
        }
        
        fetchValues()
    }
    
}

extension Habit.Card.Manager {
    
    var dailyValue: Habit.Value? { values.last }
    
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
    
    var monthlyValues: [[Habit.Value?]] {
        let totalCells = 5 * 7
        let paddingCount = totalCells - values.count
        
        var paddedValues: [Habit.Value?] = Array(repeating: nil, count: paddingCount)
        paddedValues.append(contentsOf: values.map { $0 as Habit.Value? })
        
        return stride(from: 0, to: paddedValues.count, by: 7).map { startIndex in
            Array(paddedValues[startIndex..<min(startIndex + 7, paddedValues.count)])
        }
    }
    
}

extension Habit.Card.Manager {
    
    var currentValue: Int {
        switch mode {
            case .daily: dailyValue?.currentValue ?? 0
            case .weekly: weeklyValues.reduce(0) { $0 + $1.currentValue }
            case .monthly: values.reduce(0) { $0 + $1.currentValue }
        }
    }
    
    var currentTarget: Int {
        switch mode {
            case .daily: habit.target
            case .weekly: habit.target * 7
            case .monthly: habit.target * 30
        }
    }
    
    var currentProgress: CGFloat {
        guard currentTarget > 0 else { return 0 }
        return CGFloat(currentValue) / CGFloat(currentTarget)
    }
    
    var isCompleted: Bool {
        switch kind {
            case .good: currentValue >= currentTarget
            case .bad: currentValue < currentTarget
        }
    }
    
}

extension Habit.Card.Manager {
    
    static let contentHeight: CGFloat = 155
    
    var labelBottomPadding: CGFloat {
        switch mode {
            case .daily: 20
            case .weekly: 10
            case .monthly: 14
        }
    }
    
}
