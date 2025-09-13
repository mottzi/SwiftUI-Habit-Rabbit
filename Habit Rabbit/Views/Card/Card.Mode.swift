import SwiftUI

extension Habit.Card {
    
    enum Mode: String, CaseIterable, RawRepresentable {
        case daily = "daily"
        case weekly = "weekly"
        case monthly = "monthly"
        
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

extension EnvironmentValues {
    
    @Entry var cardMode: Habit.Card.Mode? = nil
    
}
