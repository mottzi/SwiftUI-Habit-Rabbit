import SwiftUI
import SwiftData

extension Habit.Dashboard {
    @Observable
    class Manager {
        let modelContext: ModelContext
        var mode: Habit.Card.Mode { didSet { synchronizeModes() } }
        private var lastDay: Date

        private(set) var cardManagers: [Habit.Card.Manager] = []
        private var cardManagerCache: [Habit.ID: Habit.Card.Manager] = [:]
                
        init(
            mode: Habit.Card.Mode = .daily,
            lastDay: Date = .now.startOfDay,
            modelContext: ModelContext
        ) {
            self.mode = mode
            self.lastDay = lastDay
            self.modelContext = modelContext
            refreshManagers()
        }
                
        // Synchronizes the display mode of all child card managers.
        func synchronizeModes() {
            cardManagers.forEach { $0.updateMode(to: mode) }
        }
        
        // Fetches all habits from the database and synchronizes the view models.
        func refreshManagers() {
            print("📊 Synchronizing view models and habits ...")
            do {
                var newCache: [Habit.ID: Habit.Card.Manager] = [:]
                let habits = try modelContext.fetch(FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.date)]))
                
                for habit in habits {
                    if let manager = cardManagerCache[habit.id] {
                        newCache[habit.id] = manager
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
                    newCache[habit.id] = newManager
                }
                
                self.cardManagerCache = newCache
                self.cardManagers = habits.compactMap { newCache[$0.id] }
                
            } catch {
                print("Failed to fetch habits:", error)
            }
        }
    }
}
