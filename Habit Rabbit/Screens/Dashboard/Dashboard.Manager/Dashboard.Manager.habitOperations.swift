import SwiftUI

extension Habit.Dashboard.Manager {
    
    func randomizeAllHabits() {
        cardManagers.forEach { $0.randomizeMonthlyValues() }
    }
    
    func resetLatestHabits() {
        cardManagers.forEach { $0.resetDailyValue() }
    }
    
    func addHabits(_ habits: [Habit]) {
        habits.forEach { modelContext.insert(habit: $0) }
        try? modelContext.save()
        refreshCardManagers()
    }
    
    func updateHabit(
        _ habit: Habit,
        name: String,
        unit: String,
        icon: String,
        color: Color,
        target: Int,
        kind: Habit.Kind
    ) {
        habit.name = name
        habit.unit = unit
        habit.icon = icon
        habit.target = target
        habit.kind = kind
        habit.colorData = (try? NSKeyedArchiver.archivedData(
            withRootObject: UIColor(color),
            requiringSecureCoding: false)
        ) ?? Data()
        
        guard let _ = try? modelContext.save() else { return }
        refreshCardManagers()
    }
    
    func updateHabit(_ habit: Habit, with newHabit: Habit) {
        updateHabit(
            habit,
            name: newHabit.name,
            unit: newHabit.unit,
            icon: newHabit.icon,
            color: newHabit.color,
            target: newHabit.target,
            kind: newHabit.kind
        )
    }
    
    func addExampleHabits(count: Int) {
        let templates = Habit.examples
        guard !templates.isEmpty else { return }
        
        let habits = (0..<count).map { i in
            let template = templates[i % templates.count]
            return Habit(
                name: template.name,
                unit: template.unit,
                icon: template.icon,
                color: template.color,
                target: template.target,
                kind: template.kind
            )
        }
        
        addHabits(habits)
    }
    
    func deleteAllHabits() throws {
        try modelContext.delete(model: Habit.self)
        try modelContext.save()
        refreshCardManagers()
    }
    
    func deleteAllData() {
        modelContext.container.deleteAllData()
        refreshCardManagers()
    }
    
}
