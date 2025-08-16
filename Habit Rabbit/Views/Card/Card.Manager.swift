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
        print("🔄 shiftLastDay(to: \(direction)) START for \(habit.name)")
        print("   OLD lastDay: \(lastDay.formatted(date: .abbreviated, time: .omitted))")
        print("   BEFORE values: \(values.map { $0.date.formatted(date: .abbreviated, time: .omitted) })")
        
        let offset = direction == .tomorrow ? 1 : -1
        let newLastDay = Calendar.current.date(byAdding: .day, value: offset, to: lastDay)!
        lastDay = newLastDay
        
        print("   NEW lastDay: \(lastDay.formatted(date: .abbreviated, time: .omitted))")
        
        // Update values array to maintain chronological order and 30-day window
        switch direction {
            case .yesterday:
                // Going backwards: remove newest day, add older day at the beginning
                if !values.isEmpty {
                    values.removeLast()
                    print("   Removed newest day")
                }
                
                // Find the oldest day we need (29 days before newLastDay)
                let oldestNeededDate = Calendar.current.date(byAdding: .day, value: -29, to: newLastDay)!
                
                // Check if we already have this date
                if !values.contains(where: { $0.date.isSameDay(as: oldestNeededDate) }) {
                    let descriptor = Habit.Value.filterByDay(for: habit, on: oldestNeededDate)
                    let newValues = (try? modelContext.fetch(descriptor)) ?? []
                    print("   Fetched \(newValues.count) values for \(oldestNeededDate.formatted(date: .abbreviated, time: .omitted))")
                    
                    let newValue = newValues.first ?? {
                        print("   Creating new value for \(oldestNeededDate.formatted(date: .abbreviated, time: .omitted))")
                        let value = Habit.Value(habit: habit, date: oldestNeededDate)
                        modelContext.insert(value)
                        return value
                    }()
                    
                    print("   Using value: \(newValue.date.formatted(date: .abbreviated, time: .omitted))=\(newValue.currentValue)")
                    values.insert(newValue, at: 0)
                } else {
                    print("   Oldest needed date already exists in array")
                }
                
            case .tomorrow:
                // Going forwards: remove oldest day if at capacity, add newer day at the end
                if values.count >= 30 {
                    print("   Trimming old value: \(values.first?.date.formatted(date: .abbreviated, time: .omitted) ?? "nil")")
                    values.removeFirst()
                }
                
                let descriptor = Habit.Value.filterByDay(for: habit, on: newLastDay)
                let newValues = (try? modelContext.fetch(descriptor)) ?? []
                print("   Fetched \(newValues.count) values for \(newLastDay.formatted(date: .abbreviated, time: .omitted))")
                
                let newValue = newValues.first ?? {
                    print("   Creating new value for \(newLastDay.formatted(date: .abbreviated, time: .omitted))")
                    let value = Habit.Value(habit: habit, date: newLastDay)
                    modelContext.insert(value)
                    return value
                }()
                
                print("   Using value: \(newValue.date.formatted(date: .abbreviated, time: .omitted))=\(newValue.currentValue)")
                values.append(newValue)
        }
        
        // Ensure we maintain exactly 30 days
        while values.count > 30 {
            print("   Trimming excess value: \(values.first?.date.formatted(date: .abbreviated, time: .omitted) ?? "nil")")
            values.removeFirst()
        }
        
        print("   AFTER values: \(values.map { $0.date.formatted(date: .abbreviated, time: .omitted) })")
        print("🔄 shiftLastDay(to: \(direction)) END\n")
    }
    
//    func updateLastDay(to newLastDay: Date) {
//        if !lastDay.isSameDay(as: newLastDay) { lastDay = newLastDay }
//    }
    
    func updateMode(to newMode: Habit.Card.Mode) {
        if mode != newMode { mode = newMode }
    }
    
    private func fetchValues() {
        print("🔍 fetchValues() START for \(habit.name)")
        print("   lastDay: \(lastDay.formatted(date: .abbreviated, time: .omitted))")
        
        let description = Habit.Value.filterByDays(30, for: habit, endingOn: lastDay)
        guard let newValues = try? modelContext.fetch(description) else { 
            print("   ❌ Failed to fetch values")
            return 
        }
        
        print("   Fetched \(newValues.count) values from database")
        print("   Fetched dates: \(newValues.map { $0.date.formatted(date: .abbreviated, time: .omitted) })")
        print("   Fetched values: \(newValues.map { "\($0.date.formatted(date: .abbreviated, time: .omitted))=\($0.currentValue)" })")
        
        values = newValues
        
        let todayExists = values.contains {
            $0.date.isSameDay(as: self.lastDay)
        }
        
        print("   todayExists (\(lastDay.formatted(date: .abbreviated, time: .omitted))): \(todayExists)")
        
        guard todayExists == false else { 
            print("🔍 fetchValues() END - today exists\n")
            return 
        }
        print("📝 Creating missing Habit.Value for \(habit.name) on \(self.lastDay.formatted(date: .abbreviated, time: .omitted))")
        
        let todayValue = Habit.Value(habit: self.habit, date: self.lastDay)
        modelContext.insert(todayValue)
        values.append(todayValue)
        print("🔍 fetchValues() END - created today\n")
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
        print("🎲 randomizeMonthlyValues() START for \(habit.name)")
        print("   lastDay: \(lastDay.formatted(date: .abbreviated, time: .omitted))")
        print("   values array count: \(values.count)")
        print("   values array dates: \(values.map { $0.date.formatted(date: .abbreviated, time: .omitted) })")
        
        let existingValues = Dictionary(values.map { ($0.date, $0) }, uniquingKeysWith: { first, _ in first })
        print("   existingValues from in-memory array: \(existingValues.keys.map { $0.formatted(date: .abbreviated, time: .omitted) }.sorted())")
        
        var updatedCount = 0
        var createdCount = 0
        
        for dayOffset in 0..<30 {
            let date = Calendar.current.date(byAdding: .day, value: -dayOffset, to: lastDay)!.startOfDay
            let randomValue = Int.random(in: 0...habit.target * 2)
            
            // Check what's actually in the database for this date
            let dbDescriptor = Habit.Value.filterByDay(for: habit, on: date)
            let dbValues = (try? modelContext.fetch(dbDescriptor)) ?? []
            print("   Date \(date.formatted(date: .abbreviated, time: .omitted)): DB has \(dbValues.count) entries")
            
            if let existingValue = existingValues[date] {
                existingValue.currentValue = randomValue
                updatedCount += 1
                print("     → Updated in-memory value to \(randomValue)")
            } else {
                let value = Habit.Value(habit: habit, date: date, currentValue: randomValue)
                modelContext.insert(value)
                createdCount += 1
                print("     → Created NEW database entry with value \(randomValue) (⚠️ potential duplicate!)")
            }
        }
        
        print("   Summary: Updated \(updatedCount), Created \(createdCount)")
        fetchValues()
        print("🎲 randomizeMonthlyValues() END\n")
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
    
    struct DayCell {
        let date: Date
        let value: Habit.Value?
    }
    
    var monthlyValues: [[DayCell]] {
        print("📅 monthlyValues getter for \(habit.name)")
        print("   lastDay: \(lastDay.formatted(date: .abbreviated, time: .omitted))")
        print("   values array: \(values.map { "\($0.date.formatted(date: .abbreviated, time: .omitted))=\($0.currentValue)" })")
        
        let startDate = Calendar.current.date(byAdding: .day, value: -29, to: lastDay)!
        print("   startDate: \(startDate.formatted(date: .abbreviated, time: .omitted))")
        
        // determine the grid range: align last row to the week containing endDate (locale-aware)
        let lastGridWeekStart = Calendar.current.dateInterval(of: .weekOfYear, for: lastDay)!.start
        let lastGridDate = Calendar.current.date(byAdding: .day, value: 6, to: lastGridWeekStart)!
        let firstGridDate = Calendar.current.date(byAdding: .day, value: -34, to: lastGridDate)!
        print("   Grid range: \(firstGridDate.formatted(date: .abbreviated, time: .omitted)) to \(lastGridDate.formatted(date: .abbreviated, time: .omitted))")
        
        // build a lookup for quick value resolution
        let valueByDate: [Date: Habit.Value] = Dictionary(values.map { ($0.date, $0) }, uniquingKeysWith: { _, latest in latest })
        print("   valueByDate lookup keys: \(valueByDate.keys.map { $0.formatted(date: .abbreviated, time: .omitted) }.sorted())")
        
        // create 35 cells (5 weeks x 7 days), padding with nil outside the [startDate, endDate] range
        let normalizedStart = startDate.startOfDay
        
        var cellsWithValues = 0
        var cellsWithoutValues = 0
        
        // Now, flatCells will be an array of DayCell structs
        let flatCells: [DayCell] = (0..<35).map { dayOffset in
            let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: firstGridDate)!.startOfDay
            
            let value: Habit.Value?
            if date < normalizedStart || date > lastDay {
                value = nil // This is a blank cell
            } else {
                value = valueByDate[date] ?? Habit.Value(habit: habit, date: date, currentValue: 0)
                if valueByDate[date] != nil {
                    cellsWithValues += 1
                } else {
                    cellsWithoutValues += 1
                }
            }
            
            // Create and return the DayCell
            return DayCell(date: date, value: value)
        }
        
        print("   Result: \(cellsWithValues) cells with real data, \(cellsWithoutValues) cells with default values")
        print("📅 monthlyValues getter END\n")
        
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
