import SwiftUI
import SwiftData

extension Habit.Dashboard {
    
    @Observable
    class Manager {

        private(set) var lastDay: Date
        private let modelContext: ModelContext
        
        private(set) var mode: Habit.Card.Mode
        private(set) var useZoomTransition: Bool = false
        private(set) var useInlineNavTitle: Bool = false
        
        private(set) var cardManagers: [Habit.Card.Manager] = []
        
        @ObservationIgnored
        private var cardManagerCache: [Habit.ID: Habit.Card.Manager] = [:]
        
        let weekdaySymbols: [String]
        private(set) var lastDayIndex: Int
                
        init(
            mode: Habit.Card.Mode = .daily,
            lastDay: Date = .now.startOfDay,
            using modelContext: ModelContext
        ) {
            self.mode = mode
            self.lastDay = lastDay
            self.modelContext = modelContext
            
            self.weekdaySymbols = Calendar.current.weekdaySymbols
            self.lastDayIndex = Calendar.current.weekdayIndex(for: lastDay)
            
            refreshCardManagers()
        }
        
    }
    
}

extension Habit.Dashboard.Manager {
    
    // jump to yesterday or tomorrow with optimized single-day fetch
    func shiftLastDay(to direction: Habit.Card.Manager.DayShift) {
        print("* Optimized shift to: \(direction) - single fetch")
        
        // Update lastDay and lastDayIndex
        let offset = direction == .tomorrow ? 1 : -1
        lastDay = Calendar.current.date(byAdding: .day, value: offset, to: lastDay)!
        lastDayIndex = Calendar.current.weekdayIndex(for: lastDay)
        
        // Update existing card managers with the new lastDay
        for cardManager in cardManagers {
            cardManager.shiftLastDay(to: direction)
        }
    }
    
    // jump to arbitrary date with full refresh or to yesterday / tommorow with single-day-fetch
    func setLastDay(to date: Date) {
        guard !date.isSameDay(as: lastDay) else { return }
        let date = date.startOfDay
        
        let dayDifference = Calendar.current.dateComponents([.day], from: lastDay, to: date).day!
        
        // Use optimized path for single-day shifts (common case: midnight)
        if abs(dayDifference) == 1 {
            let direction: Habit.Card.Manager.DayShift = dayDifference > 0 ? .tomorrow : .yesterday
            shiftLastDay(to: direction)
        } else {
            // Fall back to full rebuild for larger jumps
            print("* Unoptimized shift to: \(date) - full rebuild")
            lastDay = date
            lastDayIndex = Calendar.current.weekdayIndex(for: date)
            deleteCardManagers()
            refreshCardManagers()
        }
    }
    
    // clear all card managers from cache
    func deleteCardManagers() {
        print("* Deleting view models ...")
        cardManagerCache.removeAll()
    }
    
    // rebuild all card managers from scratch
    func refreshCardManagers() {
        print("* Refreshing view models ...")
        var newCache: [Habit.ID: Habit.Card.Manager] = [:]
        
        let query = FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.date)])
        
        guard let habits = try? modelContext.fetch(query) else {
            print("Failed to fetch habits.")
            return
        }
        
        for habit in habits {
            if let cachedManager = cardManagerCache[habit.id] {
                newCache[habit.id] = cachedManager
                continue
            }
            
            print("Habit.Manager: 🧾 \(habit.name)")
            
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
    
    func toggleZoomTransition() {
        useZoomTransition.toggle()
    }
    
    func toggleInlineNavTitle() {
        useInlineNavTitle.toggle()
    }
        
    func updateMode(to newMode: Habit.Card.Mode) {
        if newMode == mode { return }
        mode = newMode
        synchronizeCardModes()
    }
    
    private func synchronizeCardModes() {
        cardManagers.forEach { $0.updateMode(to: mode) }
    }
    
    func weekdaySymbol(for date: Date) -> String {
        let index = Calendar.current.weekdayIndex(for: date)
        guard weekdaySymbols.indices.contains(index) else { return "?" }
        return weekdaySymbols[index]
    }
    
}

extension Habit.Dashboard.Manager {
    
    func randomizeAllHabits() {
        cardManagers.forEach { $0.randomizeMonthlyValues() }
    }
    
    func resetAllHabits() {
        cardManagers.forEach { $0.resetDailyValue() }
    }
    
    func addHabits(_ habits: [Habit]) {
        habits.forEach { modelContext.insert(habit: $0) }
        guard let _ = try? modelContext.save() else { return }
        refreshCardManagers()
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
        print("Dashboard.Manager: deleteAllHabits executed ... ")
        refreshCardManagers()
    }
    
    func deleteAllData() {
        modelContext.container.deleteAllData()
        print("Dashboard.Manager: deleteAllData executed ... ")
        refreshCardManagers()
    }
    
}
