import SwiftUI
import SwiftData

extension Habit.Dashboard {
    @Observable
    class Manager {
        var mode: Habit.Card.Mode { didSet { synchronizeModes() } }
        private var lastDay: Date
        let modelContext: ModelContext

        private(set) var cardManagers: [Habit.Card.Manager] = []
        private var cardManagerCache: [Habit.ID: Habit.Card.Manager] = [:]
                
        init(
            mode: Habit.Card.Mode = .daily,
            lastDay: Date = .now.startOfDay,
            using modelContext: ModelContext
        ) {
            self.mode = mode
            self.lastDay = lastDay
            self.modelContext = modelContext
            refreshManagers()
        }
                
        func synchronizeModes() {
            cardManagers.forEach {
                $0.updateMode(to: mode)
            }
        }
        
        // Fetches all habits from the database and synchronizes the view models.
        func refreshManagers() {
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
    }
}
