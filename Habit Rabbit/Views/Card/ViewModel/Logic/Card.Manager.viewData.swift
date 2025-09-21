import SwiftUI

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
