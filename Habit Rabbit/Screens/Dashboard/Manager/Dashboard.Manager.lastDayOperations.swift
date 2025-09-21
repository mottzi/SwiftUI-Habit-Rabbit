import SwiftUI

extension Habit.Dashboard.Manager {
    
    // jump to yesterday or tomorrow with optimized single-day fetch
    func shiftLastDay(to direction: Habit.Card.Manager.DayShiftDirection) {
        
        // Update lastDay and lastDayIndex
        let offset = direction == .tomorrow ? 1 : -1
        lastDay = Calendar.current.date(byAdding: .day, value: offset, to: lastDay)!
        lastDayIndex = Calendar.current.weekdayIndex(for: lastDay)
        
        // Update existing card managers with the new lastDay
        for cardManager in cardManagers {
            cardManager.shiftLastDay(to: direction)
        }
    }
    
    // jump to arbitrary date with full refresh or to yesterday / tommorow with single-day-fetch
    func setLastDay(to date: Date) {
        guard !date.isSameDay(as: lastDay) else { return }
        let date = date.startOfDay
        
        let dayDifference = Calendar.current.dateComponents([.day], from: lastDay, to: date).day!
        
        // Use optimized path for single-day shifts (common case: midnight)
        if abs(dayDifference) == 1 {
            let direction: Habit.Card.Manager.DayShiftDirection = dayDifference > 0 ? .tomorrow : .yesterday
            shiftLastDay(to: direction)
        } else {
            // Fall back to full rebuild for larger jumps
            lastDay = date
            lastDayIndex = Calendar.current.weekdayIndex(for: date)
            deleteCardManagers()
            refreshCardManagers()
        }
    }
    
}

extension Habit.Dashboard.Manager {
    
    func weekdaySymbol(for date: Date) -> String {
        let index = Calendar.current.weekdayIndex(for: date)
        guard weekdaySymbols.indices.contains(index) else { return "?" }
        return weekdaySymbols[index]
    }
    
}
