import SwiftUI
import SwiftData
import AppComponents

@MainActor
protocol HabitManager {
    var habitModels: [Habit] { get }
    var habitValues: [HabitValue] { get }
    var modelContext: ModelContext { get }
    
    // binding creation
    func binding(for habitID: UUID) -> Binding<Int>
    
    // data management
    func createMissingHabitValues()
    func removeHabitData()
    func resetHabitValues()
    func randomizeHabitValues()
    func addExampleHabits()
}

extension HabitManager {
    func createMissingHabitValues() {
        for habit in habitModels {
            guard !habitValues.contains(where: { $0.habitID == habit.id }) else { continue }
            modelContext.insert(HabitValue(habitID: habit.id, currentValue: 0))
        }
        
        try? modelContext.save()
    }
    
    func removeHabitData() {
        for habit in habitModels { modelContext.delete(habit) }
        for habitValue in habitValues { modelContext.delete(habitValue) }
        try? modelContext.save()
    }
    
    func resetHabitValues() {
        for habitValue in habitValues { habitValue.currentValue = 0 }
        try? modelContext.save()
    }
    
    func randomizeHabitValues() {
        let targets = Dictionary(uniqueKeysWithValues: habitModels.map { ($0.id, $0.target) })
        
        for habitValue in habitValues {
            guard let target = targets[habitValue.habitID] else { continue }
            habitValue.currentValue = Int.random(in: 0...(target * 2))
        }
        
        try? modelContext.save()
    }
    
    func addExampleHabits() {
        let examples = Habit.examples()
        let randomExamples = examples.randomElements(count: Int.random(in: 1...examples.count))
        
        for habit in randomExamples {
            modelContext.insert(habit)
            modelContext.insert(HabitValue(habitID: habit.id, currentValue: 0))
        }
        
        try? modelContext.save()
    }
    
    // use this to create a integer binding for a habit value by habit model id
    func binding(for habitID: UUID) -> Binding<Int> {
        Binding(
            get: {
                // find habit value for this habit id
                habitValues.first { $0.habitID == habitID }?.currentValue ?? 0
            },
            set: { newValue in
                // if value exists: update
                if let existingValue = habitValues.first(where: { $0.habitID == habitID }) {
                    existingValue.currentValue = newValue
                }
                // else create new value
                else {
                    let newHabitValue = HabitValue(habitID: habitID, currentValue: newValue)
                    modelContext.insert(newHabitValue)
                }
                
                // save changes
                try? modelContext.save()
            }
        )
    }
}
