import SwiftUI
import SwiftData

extension Habit.Dashboard {
    
    @Observable
    class Manager {

        var lastDay: Date
        var modelContext: ModelContext
        
        var lastDayIndex: Int
        let weekdaySymbols: [String]
                
        var modeCache: Habit.Card.Mode?
        var mode: Habit.Card.Mode {
            get { loadMode() }
            set { saveMode(newValue) }
        }
        
        @ObservationIgnored
        var cardManagerCache: [PersistentIdentifier: Habit.Card.Manager] = [:]
        var cardManagers: [Habit.Card.Manager] = []
                
        init(
            mode: Habit.Card.Mode? = nil,
            lastDay: Date = .now.startOfDay,
            using modelContext: ModelContext
        ) {
            self.lastDay = lastDay
            self.weekdaySymbols = Calendar.current.weekdaySymbols
            self.lastDayIndex = Calendar.current.weekdayIndex(for: lastDay)
            self.modelContext = modelContext
            
            if let mode {
                self.modeCache = mode
                UserDefaults.standard.set(mode.rawValue, forKey: "dashboardMode")
            }
                                        
            refreshCardManagers()
        }
        
    }
    
}
