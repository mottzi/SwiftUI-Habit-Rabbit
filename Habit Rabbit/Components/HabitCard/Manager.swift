import SwiftUI
import SwiftData

extension Habit.Card {
    @Observable
    class Manager {
        private let modelContext: ModelContext
        let habit: Habit
        let lastDay: Date
        
        var values: [Habit.Value] = []
        
        init(modelContext: ModelContext, habit: Habit, lastDay: Date) {
            self.modelContext = modelContext
            self.habit = habit
            self.lastDay = lastDay
            
            fetchValues()
        }
        
        // fetch the values of the last 30 days
        func fetchValues() {
            print(" ⬇ \(habit.name): fetching values")
            do {
                let description = Habit.Value.filterByDays(30, for: habit, endingOn: lastDay)
                values = try modelContext.fetch(description)                
            } catch {
                print("Failed to fetch values for \(habit.name):", error)
            }
        }
        
        // update the last fetched value
        func updateRandomValue() {
            if let value = values.last {
                value.currentValue = Int.random(in: 0...habit.target * 2)
            }
        }
    }
}
