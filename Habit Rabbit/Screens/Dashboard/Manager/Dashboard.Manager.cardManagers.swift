import SwiftUI
import SwiftData

extension Habit.Dashboard.Manager {
    
    // clear all card managers from cache
    func deleteCardManagers() {
        cardManagerCache.removeAll()
    }
    
    // rebuild all card managers from scratch
    func refreshCardManagers() {
        var newCache: [PersistentIdentifier: Habit.Card.Manager] = [:]
        
        let query = FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.date)])
        
        guard let habits = try? modelContext.fetch(query) else { return }
        
        for habit in habits {
            if let cachedManager = cardManagerCache[habit.id] {
                newCache[habit.id] = cachedManager
                continue
            }
            
            newCache[habit.id] = Habit.Card.Manager(
                for: habit,
                until: lastDay,
                mode: mode,
                using: modelContext
            )
        }
        
        self.cardManagerCache = newCache
        self.cardManagers = habits.compactMap { newCache[$0.id] }
    }
    
}

extension Habit.Dashboard.Manager {
    
    func updateMode(to newMode: Habit.Card.Mode) {
        if newMode == mode { return }
        mode = newMode
        synchronizeCardModes()
    }
    
    func synchronizeCardModes() {
        cardManagers.forEach { $0.updateMode(to: mode) }
    }
    
}
