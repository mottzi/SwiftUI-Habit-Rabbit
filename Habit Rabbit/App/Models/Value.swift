import SwiftUI
import SwiftData

extension Habit {

    @Model
    class Value {
        
        @Relationship
        var habit: Habit?
        
        var date: Date
        var currentValue: Int
        
        init(habit: Habit, date: Date, currentValue: Int = 0) {
            self.habit = habit
            self.date = date.startOfDay
            self.currentValue = currentValue
        }
        
    }
    
}

extension Habit.Value {

    static func filterByDay(for habit: Habit, on date: Date) -> FetchDescriptor<Habit.Value> {
        filterByDays(1, for: habit, endingOn: date)
    }
    
    static func filterByDays(_ days: Int, for habit: Habit, endingOn date: Date) -> FetchDescriptor<Habit.Value> {
        let habitID = habit.id
        
        let today = Calendar.current.startOfDay(for: date)
        let rangeStart = Calendar.current.date(byAdding: .day, value: -(days-1), to: today)!
        let rangeEnd = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        let predicate = #Predicate<Habit.Value> { value in
            value.habit?.id == habitID
            && value.date >= rangeStart && value.date < rangeEnd
        }
        
        let sortByDate = SortDescriptor(\Habit.Value.date)
        var descriptor = FetchDescriptor(predicate: predicate, sortBy: [sortByDate])
        descriptor.fetchLimit = days
        descriptor.relationshipKeyPathsForPrefetching = [\Habit.Value.habit]
        
        return descriptor
    }
    
}
