import SwiftUI

extension Habit.Card.Manager {
    
    enum DayShiftDirection {
        case yesterday
        case tomorrow
    }
    
    func shiftLastDay(to direction: DayShiftDirection) {
        switch direction {
            case .yesterday: shiftToYesterday()
            case .tomorrow: shiftToTomorrow()
        }
    }
    
}

extension Habit.Card.Manager {
    
    func shiftToYesterday() {
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
    
    func shiftToTomorrow() {
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
    
}

extension Habit.Card.Manager {
    
    private func cleanupCache() {
        // Keep cache size reasonable by maintaining a window around lastDay (30 days in each direction)
        let pastCutoff = lastDay.shift(days: -30)
        let futureCutoff = lastDay.shift(days: 30)
        
        valueCache = valueCache.filter { date, _ in
            (pastCutoff...futureCutoff).contains(date)
        }
    }
    
}
