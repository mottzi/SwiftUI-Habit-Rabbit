import SwiftUI
import SwiftData

extension Habit.Dashboard {
    @Observable
    class Manager {
        // MARK: State Properties
        var mode: Habit.Card.Mode
        var lastDay: Date
        
        var managers: [Habit.Card.Manager] = []
        private var managerCache: [Habit.ID: Habit.Card.Manager] = [:]
        
        // MARK: Dependencies
        let modelContext: ModelContext
        
        init(mode: Habit.Card.Mode = .daily, lastDay: Date = .now.startOfDay, modelContext: ModelContext) {
            self.mode = mode
            self.lastDay = lastDay
            self.modelContext = modelContext
            
            // Perform the initial data fetch upon creation.
            refreshManagers()
        }
                
        // Synchronizes the display mode of all child card managers.
        func refreshManagerModes() {
            managers.forEach { $0.updateMode(mode) }
        }
        
        // Fetches all habits from the database and synchronizes the view models.
        func refreshManagers() {
            print("📊 Synchronizing view models and habits ...")
            do {
                var newManagerCache: [Habit.ID: Habit.Card.Manager] = [:]
                let habits = try modelContext.fetch(FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.date)]))
                
                for habit in habits {
                    if let manager = managerCache[habit.id] {
                        newManagerCache[habit.id] = manager
                        continue
                    }
                    
                    print("Habit: \(habit.name)")
                    print("    🧾 creating view model")
                    let newManager = Habit.Card.Manager(
                        for: habit,
                        until: lastDay,
                        mode: mode,
                        in: modelContext
                    )
                    newManagerCache[habit.id] = newManager
                }
                
                self.managerCache = newManagerCache
                self.managers = habits.compactMap { newManagerCache[$0.id] }
                
            } catch {
                print("Failed to fetch habits:", error)
            }
        }
    }
}
