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
        let descriptor = Habit.Value.filterBy(day: date, for: habit)
        if let existing = (try? modelContext.fetch(descriptor))?.first {
            return existing
        } else {
            let newValue = Habit.Value(habit: habit, date: date)
            modelContext.insert(newValue)
            return newValue
        }
    }
    
    private func fetchValues() {
        // fetch 30 day window of values ending on lastDay
        let description = Habit.Value.filterBy(days: 30, endingOn: lastDay, for: habit)
        guard let newValues = try? modelContext.fetch(description) else { return }
        values = newValues
        
        // abort if lastDay already exists
        guard !values.contains(where: { $0.date.isSameDay(as: lastDay) }) else { return }
        
        // create and save lastDay value
        let lastDayValue = Habit.Value(habit: self.habit, date: lastDay)
        modelContext.insert(lastDayValue)
        values.append(lastDayValue)
    }
    
    private func shiftToYesterday() {
        // 1. Get the value for the new lastDay (yesterday)
        let newLastDay = lastDay.yesterday
        let newLastDayValue = fetchOrCreateValue(for: newLastDay)

        // 2. Remove the OLD lastDay's value from the array
        let oldLastDay = self.lastDay
        values.removeAll(where: { $0.date.isSameDay(as: oldLastDay) })

        // 3. Insert the new oldest day's value (only if not already present)
        let newOldestDay = Calendar.current.date(byAdding: .day, value: -29, to: newLastDay)!
        if !values.contains(where: { $0.date.isSameDay(as: newOldestDay) }) {
            let newOldestValue = fetchOrCreateValue(for: newOldestDay)
            values.insert(newOldestValue, at: 0)
        }

        // 4. Update lastDay and ensure its value is at the end
        lastDay = newLastDay
        
        // Remove any existing entry for newLastDay and append it at the end
        values.removeAll(where: { $0.date.isSameDay(as: newLastDay) })
        values.append(newLastDayValue)
    }
    
    private func shiftToTomorrow() {
        // 1. Get the value for the new lastDay (tomorrow)
        let newLastDay = lastDay.tomorrow
        let newLastDayValue = fetchOrCreateValue(for: newLastDay)
        
        // 2. Calculate which day is no longer in the 30-day window
        let oldestDayToRemove = Calendar.current.date(byAdding: .day, value: -30, to: newLastDay)!
        values.removeAll(where: { $0.date.isSameDay(as: oldestDayToRemove) })
        
        // 3. Update lastDay
        lastDay = newLastDay
        
        // 4. Remove any existing entry for newLastDay and append it at the end
        values.removeAll(where: { $0.date.isSameDay(as: newLastDay) })
        values.append(newLastDayValue)
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
        let firstDay = lastDay.shift(days: -29)
        let existingValues = Dictionary(values.map { ($0.date, $0) }, uniquingKeysWith: { _, latest in latest })
        
        let gridLastWeekFirstDay = Calendar.current.dateInterval(of: .weekOfYear, for: lastDay)!.start
        let gridLastDay = gridLastWeekFirstDay.shift(days: 6)
        let gridFirstDay = gridLastDay.shift(days: -41)
        
//        print("-------------------------------------------")
//        let formatter = DateFormatter()
//        formatter.dateStyle = .full      // Sonntag, 17. August 2025
//        formatter.timeStyle = .medium    // 00:00:00
//        formatter.timeZone = .current    // deine lokale Zeitzone
//        formatter.locale = .current      // deine Spracheinstellungen
//        print(gridLastWeekFirstDay.debug, "gridLastWeekFirstDay")
//        print(gridLastDay.debug, "gridLastDay")
//        print(gridFirstDay.debug, "gridFirstDay")
//        print("-------------------------------------------")
//        print(firstDay.debug, "firstDay")
//        print(lastDay.debug, "lastDay")

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
