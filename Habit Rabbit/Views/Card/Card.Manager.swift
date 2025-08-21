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
        
        @ObservationIgnored 
        private var valueCache: [Date: Habit.Value] = [:]

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
    
    enum DayShift {
        case yesterday
        case tomorrow
    }
    
    func shiftLastDay(to direction: DayShift) {
        // add new value
        switch direction {
            case .yesterday: shiftToYesterday()
            case .tomorrow: shiftToTomorrow()
        }
    }
    
    func updateMode(to newMode: Habit.Card.Mode) {
        if mode != newMode { mode = newMode }
    }
    
}

extension Habit.Card.Manager {
    
    private func fetchOrCreateValue(for date: Date) -> Habit.Value {
        if let cachedValue = valueCache[date] {
            return cachedValue
        }
        
        let descriptor = Habit.Value.filterBy(day: date, for: habit)
        let fetchedValue = (try? modelContext.fetch(descriptor))?.first
        ?? {
            let newValue = Habit.Value(habit: habit, date: date)
            modelContext.insert(newValue)
            return newValue
        }()
        
        valueCache[date] = fetchedValue
        return fetchedValue
    }
    
    private func fetchValues() {
        // fetch core 30 day window for active values
        let coreDescription = Habit.Value.filterBy(days: 30, endingOn: lastDay, for: habit)
        guard let coreValues = try? modelContext.fetch(coreDescription) else { return }
        values = coreValues
        
        // fetch extended window: additional 14 days in past and future for cache pre-loading
        let pastEnd = lastDay.shift(days: -30) // day before the 30-day window starts
        let pastDescription = Habit.Value.filterBy(days: 14, endingOn: pastEnd, for: habit)
        let pastValues = (try? modelContext.fetch(pastDescription)) ?? []
        
        let futureStart = lastDay.tomorrow
        let futureEnd = futureStart.shift(days: 14)
        let futureDescription = Habit.Value.filterBy(days: 14, endingOn: futureEnd, for: habit)
        let futureValues = (try? modelContext.fetch(futureDescription)) ?? []
        
        // populate cache with all fetched values (core + extended)
        for value in coreValues + pastValues + futureValues {
            valueCache[value.date] = value
        }
        
        // create lookup dictionary for efficient date checking
        let existingValues = Dictionary(values.map { ($0.date, $0) }, uniquingKeysWith: { _, latest in latest })
        
        // abort if lastDay already exists
        guard existingValues[lastDay] == nil else { return }
        
        // create and save lastDay value
        let lastDayValue = Habit.Value(habit: self.habit, date: lastDay)
        modelContext.insert(lastDayValue)
        values.append(lastDayValue)
        valueCache[lastDay] = lastDayValue
    }
    
    private func shiftToYesterday() {
        // 1. Get the value for the new lastDay (yesterday)
        let newLastDay = lastDay.yesterday
        let newLastDayValue = fetchOrCreateValue(for: newLastDay)

        // 2. Create lookup dictionary for efficient operations
        let existingValues = Dictionary(values.map { ($0.date, $0) }, uniquingKeysWith: { _, latest in latest })
        
        // 3. Cache values that are being removed from active window but keep them in cache
        let oldLastDay = self.lastDay
        if let removedValue = existingValues[oldLastDay] {
            valueCache[oldLastDay] = removedValue
        }
        
        // 4. Remove the OLD lastDay's value and build new values array
        var newValues = values.filter { !$0.date.isSameDay(as: oldLastDay) && !$0.date.isSameDay(as: newLastDay) }

        // 5. Insert the new oldest day's value (only if not already present)
        let newOldestDay = newLastDay.shift(days: -29)
        if existingValues[newOldestDay] == nil {
            let newOldestValue = fetchOrCreateValue(for: newOldestDay)
            newValues.insert(newOldestValue, at: 0)
        }

        // 6. Update lastDay and ensure its value is at the end
        lastDay = newLastDay
        newValues.append(newLastDayValue)
        values = newValues
        
        // 7. Cleanup cache periodically
        cleanupCache()
    }
    
    private func shiftToTomorrow() {
        // 1. Get the value for the new lastDay (tomorrow)
        let newLastDay = lastDay.tomorrow
        let newLastDayValue = fetchOrCreateValue(for: newLastDay)
        
        // 2. Calculate which day is no longer in the 30-day window
        let oldestDayToRemove = newLastDay.shift(days: -30)
        
        // 3. Cache values that are being removed from active window
        let existingValues = Dictionary(values.map { ($0.date, $0) }, uniquingKeysWith: { _, latest in latest })
        if let removedValue = existingValues[oldestDayToRemove] {
            valueCache[oldestDayToRemove] = removedValue
        }
        
        // 4. Filter out the oldest day and any existing entry for newLastDay
        values = values.filter { !$0.date.isSameDay(as: oldestDayToRemove) && !$0.date.isSameDay(as: newLastDay) }
        
        // 5. Update lastDay and append new value
        lastDay = newLastDay
        values.append(newLastDayValue)
        
        // 6. Cleanup cache periodically
        cleanupCache()
    }
    
    private func cleanupCache() {
        // Keep cache size reasonable by maintaining a window around lastDay (30 days in each direction)
        let pastCutoff = lastDay.shift(days: -30)
        let futureCutoff = lastDay.shift(days: 30)
        
        valueCache = valueCache.filter { date, _ in
            (pastCutoff...futureCutoff).contains(date)
        }
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
        // create new values array
        var newValues: [Habit.Value] = []
        // create lookup of existing values
        let existingValues = Dictionary(values.map { ($0.date, $0) }, uniquingKeysWith: { first, _ in first })

        // randomize values for the last 30 days
        for dayOffset in (0..<30).reversed() {
            let day = lastDay.shift(days: -dayOffset)
            let randomValue = Int.random(in: 0...habit.target * 2)
                        
            if let existingValue = existingValues[day] {
                // update existing value
                existingValue.currentValue = randomValue
                newValues.append(existingValue)
            } else {
                // create missing value
                let value = Habit.Value(habit: habit, date: day, currentValue: randomValue)
                modelContext.insert(value)
                newValues.append(value)
            }
        }
        
        // update with randomized values
        values = newValues
        
        // update cache with all randomized values
        for value in newValues {
            valueCache[value.date] = value
        }
    }
    
}

extension Habit.Card.Manager {
    
    var dailyValue: Habit.Value? { values.last }
    
    var weeklyValues: [Habit.Value] {
        let firstDay = lastDay.shift(days: -6)
        let allDays = (0..<7).map {
            firstDay.shift(days: $0)
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
        let firstDay = lastDay.shift(days: -29)
        let existingValues = Dictionary(values.map { ($0.date, $0) }, uniquingKeysWith: { _, latest in latest })
        
        let gridLastWeekFirstDay = Calendar.current.dateInterval(of: .weekOfYear, for: lastDay)!.start
        let gridLastDay = gridLastWeekFirstDay.shift(days: 6)
        let gridFirstDay = gridLastDay.shift(days: -41)

        let cells = (0..<42).map { offset in
            let day = gridFirstDay.shift(days: offset)

            let value = (firstDay...lastDay).contains(day)
                ? existingValues[day] ?? Habit.Value(habit: habit, date: day, currentValue: 0)
                : nil

            return DayCell(date: day, value: value)
        }
    
        let allRows = stride(from: 0, to: cells.count, by: 7).map { startIndex in
            Array(cells[startIndex..<min(startIndex + 7, cells.count)])
        }
        
        // Only show first row when lastDay is at the start of the week (Monday)
        let lastDayWeekdayIndex = Calendar.current.weekdayIndex(for: lastDay)
        let shouldShowFirstRow = lastDayWeekdayIndex == 0
        
        return shouldShowFirstRow ? allRows : Array(allRows.dropFirst())
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
    static let cubesGridHeight: CGFloat = 126 // 6 rows: 6 * 16 (cube) + 5 * 6 (spacing) = 126
    
    var labelBottomPadding: CGFloat {
        switch mode {
            case .daily: 20
            case .weekly: 10
            case .monthly: 14
        }
    }
    
}
