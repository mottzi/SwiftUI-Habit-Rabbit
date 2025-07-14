
import Foundation
import SwiftUI

protocol HabitManaging {
    var endDay: Date { get }
    var viewType: HabitCardType { get }

    var habits: [Habit] { get }
    var values: [Habit.Value] { get }
    var entries: [Habit.Entry] { get }
    var valueLookup: [Habit.ID: [Date: Habit.Value]] { get }
    
    func updatedValueLookup() -> [Habit.ID: [Date: Habit.Value]]
    func getTodayValue(of habit: Habit) -> Habit.Value?
    func createEntry(for habit: Habit) -> Habit.Entry?
}

extension HabitManaging {
    var entries: [Habit.Entry] {
        habits.compactMap { habit in
            createEntry(for: habit)
        }
    }
    
    func updatedValueLookup() -> [Habit.ID: [Date: Habit.Value]] {
        var lookup: [Habit.ID: [Date: Habit.Value]] = [:]
        
        for value in values {
            guard let habitID = value.habit?.id else { continue }
            let date = Calendar.current.startOfDay(for: value.date)
            
            if lookup[habitID] == nil {
                lookup[habitID] = [:]
            }
            lookup[habitID]?[date] = value
        }
        
        return lookup
    }
    
    func createEntry(for habit: Habit) -> Habit.Entry? {
        let today = Calendar.current.startOfDay(for: endDay)
        guard let todayValue = valueLookup[habit.id]?[today] else { return nil }
        
        let weeklyValues = (0..<7).map { offset in
            let date = Calendar.current.date(byAdding: .day, value: offset - 6, to: endDay)!
            let dayDate = Calendar.current.startOfDay(for: date)
            guard let value = valueLookup[habit.id]?[dayDate] else { return 0 }
            return value.currentValue
        }
        
        return Habit.Entry(
            habit: habit,
            mode: viewType,
            currentDayValue: todayValue,
            dailyValue: todayValue.currentValue,
            weeklyValues: weeklyValues
        )
    }
    
    func getTodayValue(of habit: Habit) -> Habit.Value? {
        let today = Calendar.current.startOfDay(for: endDay)
        guard let value = valueLookup[habit.id]?[today] else { return nil }
        return value
    }
}
