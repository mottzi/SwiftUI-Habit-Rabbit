import SwiftUI
import SwiftData

extension Habit.Card {
    
    @Observable
    class Manager/*: Hashable*/ {

//        static func == (lhs: Manager, rhs: Manager) -> Bool {
//            lhs.habit.id == rhs.habit.id
//        }
//        
//        func hash(into hasher: inout Hasher) {
//            hasher.combine(habit.id)
//        }
        
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
        
//    private func fetchValues() {
//        let description = Habit.Value.filterByDays(30, for: habit, endingOn: lastDay)
//        guard let newValues = try? modelContext.fetch(description) else { return }
//        values = newValues
//    }
    
    private func fetchValues() {
        let description = Habit.Value.filterByDays(30, for: habit, endingOn: lastDay)
        guard let newValues = try? modelContext.fetch(description) else { return }
        values = newValues
        
        // ⬇️ ADD THIS ENTIRE BLOCK ⬇️
        
        // After fetching, ensure a value object exists for the current 'lastDay'.
        // This handles the case where the app is opened on a new day for the first time.
        let todayExists = values.contains { value in
            Calendar.current.isDate(value.date, inSameDayAs: self.lastDay)
        }
        
        if !todayExists {
            print("📝 Creating missing Habit.Value for \(habit.name) on \(self.lastDay.formatted(date: .abbreviated, time: .omitted))")
            
            // 1. Create the new value object for today.
            let todayValue = Habit.Value(habit: self.habit, date: self.lastDay)
            
            // 2. Insert it into the database context.
            modelContext.insert(todayValue)
            
            // 3. Append it to our local array so the UI updates immediately.
            values.append(todayValue)
        }
    }
    
    func updateMode(to newMode: Habit.Card.Mode) {
        if mode != newMode { mode = newMode }
    }
    
    enum DayDirection {
        case yesterday
        case tomorrow
    }
    
    func updateLastDay(to newLastDay: Date) {
        if !lastDay.isSameDay(as: newLastDay) { lastDay = newLastDay }
    }
    
    /// Optimized function for day-by-day navigation
    /// - Parameter direction: Either .yesterday or .tomorrow
    func refreshLastDay(direction: DayDirection) {
        let offset = direction == .tomorrow ? 1 : -1
        let newLastDay = Calendar.current.date(byAdding: .day, value: offset, to: lastDay)!
        
        // Update lastDay
        lastDay = newLastDay
        
        // Fetch the new day value
        let descriptor = Habit.Value.filterByDay(for: habit, on: newLastDay)
        let newValues = (try? modelContext.fetch(descriptor)) ?? []
        
        // Get or create the value for the new day
        let newValue = newValues.first ?? {
            let value = Habit.Value(habit: habit, date: newLastDay)
            modelContext.insert(value)
            return value
        }()
        
        // Simply append or prepend based on direction
        if direction == .tomorrow {
            values.append(newValue)
        } else {
            values.insert(newValue, at: 0)
        }
        
        // Remove the oldest value to maintain 30-day window
        if values.count > 30 {
            if direction == .tomorrow {
                values.removeFirst()
            } else {
                values.removeLast()
            }
        }
    }
    
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
