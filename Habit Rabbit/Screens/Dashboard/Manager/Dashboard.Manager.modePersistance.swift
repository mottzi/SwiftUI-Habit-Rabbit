import SwiftUI

extension Habit.Dashboard.Manager {
    
    func loadMode() -> Habit.Card.Mode {
        if let modeCache { return modeCache }
        else if let rawValue = UserDefaults.standard.string(forKey: "dashboardMode"),
                let mode = Habit.Card.Mode(rawValue: rawValue) {
            modeCache = mode
            return mode
        } else {
            modeCache = .daily
            return .daily
        }
    }
    
    func saveMode(_ newMode: Habit.Card.Mode) {
        modeCache = newMode
        UserDefaults.standard.set(newMode.rawValue, forKey: "dashboardMode")
        synchronizeCardModes()
    }
    
}
