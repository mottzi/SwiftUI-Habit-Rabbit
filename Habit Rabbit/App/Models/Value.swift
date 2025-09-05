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

    static func filterBy(day date: Date, for habit: Habit) -> FetchDescriptor<Habit.Value> {
        filterBy(days: 1, endingOn: date, for: habit)
    }
    
    static func filterBy(days: Int, endingOn date: Date, for habit: Habit) -> FetchDescriptor<Habit.Value> {
        let habitID = habit.id
        
        let today = Calendar.current.startOfDay(for: date)
        let rangeStart = Calendar.current.date(byAdding: .day, value: -(days-1), to: today)!
        let rangeEnd = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        let predicate = #Predicate<Habit.Value> { value in
//            value.habit?.id == habitID
            value.habit?.persistentModelID == habitID
            && value.date >= rangeStart && value.date < rangeEnd
        }
        
        let sortByDate = SortDescriptor(\Habit.Value.date)
        var descriptor = FetchDescriptor(predicate: predicate, sortBy: [sortByDate])
        descriptor.fetchLimit = days
        descriptor.relationshipKeyPathsForPrefetching = [\Habit.Value.habit]
        
        return descriptor
    }
    
}
