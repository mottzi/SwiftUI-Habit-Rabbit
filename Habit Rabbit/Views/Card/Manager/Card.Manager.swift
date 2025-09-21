import SwiftUI
import SwiftData

extension Habit.Card {
    
    @Observable
    class Manager {
        
        let habit: Habit
        let modelContext: ModelContext
        
        var lastDay: Date
        var mode: Habit.Card.Mode
        
        @ObservationIgnored
        var valueCache: [Date: Habit.Value] = [:]
        var values: [Habit.Value] = []

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
