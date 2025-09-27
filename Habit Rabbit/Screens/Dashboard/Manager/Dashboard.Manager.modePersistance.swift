import SwiftUI

extension Habit.Dashboard.Manager {
    
    func loadMode() -> Habit.Card.Mode {
        // return cached mode
        if let modeCache { return modeCache }
        // fetch and cache mode
        else if let rawValue = UserDefaults.standard.string(forKey: "dashboardMode"),
                let mode = Habit.Card.Mode(rawValue: rawValue) {
            modeCache = mode
            return mode
        }
        // return default mode on failure
        else {
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
