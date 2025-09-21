import SwiftUI

extension Habit.Card.Manager {
    
    func fetchOrCreateValue(for date: Date) -> Habit.Value {
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
    
    func fetchValues() {
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
            let randomValue = Int.random(in: Int(Double(habit.target) * 0.8)...habit.target * 2)
            
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
