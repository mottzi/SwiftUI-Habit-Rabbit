import SwiftUI

extension Habit.Card {
    
    enum Mode: String, CaseIterable, RawRepresentable, Identifiable {
        case daily = "daily"
        case weekly = "weekly"
        case monthly = "monthly"
        
        var id: Self { self }
        
        var localizedTitle: LocalizedStringKey {
            switch self {
                case .daily: "Daily"
                case .weekly: "Weekly"
                case .monthly: "Monthly"
            }
        }
    }
    
    func cardMode(_ mode: Habit.Card.Mode) -> some View {
        self.environment(\.cardMode, mode)
    }
    
}

extension Habit.Card.Manager {
    
    func updateMode(to newMode: Habit.Card.Mode) {
        if mode != newMode { mode = newMode }
    }
    
}

extension EnvironmentValues {
    
    @Entry var cardMode: Habit.Card.Mode? = nil
    
}
