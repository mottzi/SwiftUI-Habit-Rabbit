import SwiftUI
import SwiftData
import Observation

extension Habit.Dashboard {
    
    @Observable
    class Manager {

        private let lastDay: Date
        private let modelContext: ModelContext
        
        private(set) var mode: Habit.Card.Mode
        private(set) var cardManagers: [Habit.Card.Manager] = []
        
        @ObservationIgnored
        private var cardManagerCache: [Habit.ID: Habit.Card.Manager] = [:]
                
        init(
            mode: Habit.Card.Mode = .daily,
            lastDay: Date = .now.startOfDay,
            using modelContext: ModelContext
        ) {
            self.mode = mode
            self.lastDay = lastDay
            self.modelContext = modelContext
            
            refreshCardManagers()
        }
        
        func refreshCardManagers() {
            print("📊 Synchronizing view models and habits ...")
            do {
                var newCache: [Habit.ID: Habit.Card.Manager] = [:]
                let habits = try modelContext.fetch(FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.date)]))
                
                for habit in habits {
                    if let cachedManager = cardManagerCache[habit.id] {
                        newCache[habit.id] = cachedManager
                        continue
                    }
                    
                    print("Habit: \(habit.name)")
                    print("    🧾 creating view model")
                    
                    newCache[habit.id] = Habit.Card.Manager(
                        for: habit,
                        until: lastDay,
                        mode: mode,
                        using: modelContext
                    )
                }
                
                self.cardManagerCache = newCache
                self.cardManagers = habits.compactMap { newCache[$0.id] }
                
            } catch {
                print("Failed to fetch habits:", error)
            }
        }
        
        func updateMode(_ newMode: Habit.Card.Mode) {
            if newMode == mode { return }
            mode = newMode
            synchronizeModes()
        }
                
        func synchronizeModes() {
            cardManagers.forEach { $0.updateMode(to: mode) }
        }
        
    }
    
}

extension Habit.Dashboard.Manager {
    
    func randomizeAllHabits() {
        cardManagers.forEach { $0.randomizeMonthlyValues() }
    }
    
    func resetAllHabits() {
        cardManagers.forEach { $0.resetDailyValue() }
    }
    
    func addHabit(_ habit: Habit) throws {
        modelContext.insert(habit)
        try modelContext.save()
        refreshCardManagers()
    }
    
    func addHabits(_ habits: [Habit]) throws {
        habits.forEach { modelContext.insert($0) }
        try modelContext.save()
        refreshCardManagers()
    }
    
    func addExampleHabits(count: Int) throws {
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
        
        try addHabits(habits)
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
