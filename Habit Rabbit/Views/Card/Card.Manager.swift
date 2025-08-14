import SwiftUI
import SwiftData

extension Habit.Card {
    
    @Observable
    class Manager {
        
        let habit: Habit
        let modelContext: ModelContext
        
        private(set) var lastDay: Date
        private(set) var mode: Habit.Card.Mode
        
        private var values: [Habit.Value] = []

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
    
    enum RelativeDay {
        case yesterday
        case tomorrow
    }
    
    func shiftLastDay(to direction: RelativeDay) {
        let offset = direction == .tomorrow ? 1 : -1
        let newLastDay = Calendar.current.date(byAdding: .day, value: offset, to: lastDay)!
        lastDay = newLastDay
        
        let descriptor = Habit.Value.filterByDay(for: habit, on: newLastDay)
        let newValues = (try? modelContext.fetch(descriptor)) ?? []
        
        // Get or create the value for the new day
        let newValue = newValues.first ?? {
            let value = Habit.Value(habit: habit, date: newLastDay)
            modelContext.insert(value)
            return value
        }()
        
        // Simply append or prepend based on direction
        switch direction {
            case .yesterday: values.insert(newValue, at: 0)
            case .tomorrow: values.append(newValue)
        }
        
        guard values.count > 30 else { return }
        
        // Remove the oldest value to maintain 30-day window
        switch direction {
            case .yesterday: values.removeLast()
            case .tomorrow: values.removeFirst()
        }
    }
    
    func updateLastDay(to newLastDay: Date) {
        if !lastDay.isSameDay(as: newLastDay) { lastDay = newLastDay }
    }
    
    func updateMode(to newMode: Habit.Card.Mode) {
        if mode != newMode { mode = newMode }
    }
    
    private func fetchValues() {
        let description = Habit.Value.filterByDays(30, for: habit, endingOn: lastDay)
        guard let newValues = try? modelContext.fetch(description) else { return }
        values = newValues
        
        let todayExists = values.contains {
            $0.date.isSameDay(as: self.lastDay)
        }
        
        guard todayExists == false else { return }
        print("📝 Creating missing Habit.Value for \(habit.name) on \(self.lastDay.formatted(date: .abbreviated, time: .omitted))")
        
        let todayValue = Habit.Value(habit: self.habit, date: self.lastDay)
        modelContext.insert(todayValue)
        values.append(todayValue)
    }
        
}

extension Habit.Card.Manager {
    
    func resetDailyValue() {
        dailyValue?.currentValue = 0
    }
    
    func randomizeDailyValue() {
        dailyValue?.currentValue = Int.random(in: 0...habit.target * 2)
    }
    
    func randomizeName() {
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
        let startDate = Calendar.current.date(byAdding: .day, value: -29, to: lastDay)!

        // determine the grid range: align last row to the week containing endDate (locale-aware)
        let lastGridWeekStart = Calendar.current.dateInterval(of: .weekOfYear, for: lastDay)!.start
        let lastGridDate = Calendar.current.date(byAdding: .day, value: 6, to: lastGridWeekStart)!
        let firstGridDate = Calendar.current.date(byAdding: .day, value: -34, to: lastGridDate)!

        // build a lookup for quick value resolution
        let valueByDate: [Date: Habit.Value] = Dictionary(values.map { ($0.date, $0) }, uniquingKeysWith: { _, latest in latest })

        // create 35 cells (5 weeks x 7 days), padding with nil outside the [startDate, endDate] range
        let normalizedStart = startDate.startOfDay
        let flatCells: [Habit.Value?] = (0..<35).map { dayOffset in
            let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: firstGridDate)!.startOfDay
            if date < normalizedStart || date > lastDay {
                return nil
            } else {
                return valueByDate[date] ?? Habit.Value(habit: habit, date: date, currentValue: 0)
            }
        }

        // chunk into weeks
        return stride(from: 0, to: flatCells.count, by: 7).map { startIndex in
            Array(flatCells[startIndex..<min(startIndex + 7, flatCells.count)])
        }
    }
    
}

extension Habit.Card.Manager {
    
    func currentValue(for mode: Habit.Card.Mode? = nil) -> Int {
        switch mode ?? self.mode {
            case .daily: dailyValue?.currentValue ?? 0
            case .weekly: weeklyValues.reduce(0) { $0 + $1.currentValue }
            case .monthly: values.reduce(0) { $0 + $1.currentValue }
        }
    }
    
    func currentTarget(for mode: Habit.Card.Mode? = nil) -> Int {
        switch mode ?? self.mode {
            case .daily: habit.target
            case .weekly: habit.target * 7
            case .monthly: habit.target * 30
        }
    }
    
    func isCompleted(for mode: Habit.Card.Mode? = nil) -> Bool {
        switch kind {
            case .good: currentValue(for: mode) >= currentTarget(for: mode)
            case .bad: currentValue(for: mode) < currentTarget(for: mode)
        }
    }
    
}

extension Habit.Card.Manager {
    
    static let cardHeight: CGFloat = 232
    static let cornerRadius: CGFloat = 24
    static let contentHeight: CGFloat = 155
    
    var labelBottomPadding: CGFloat {
        switch mode {
            case .daily: 20
            case .weekly: 10
            case .monthly: 14
        }
    }
    
}
