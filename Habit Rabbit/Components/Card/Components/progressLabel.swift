import SwiftUI

extension Habit.Card {
    
    var progressLabel: some View {
        Habit.ProgressLabel(
            currentValue: cardManager.currentValue(for: mode),
            target: cardManager.habit.target,
            unit: cardManager.unit
        )
        .animation(.bouncy, value: cardManager.currentValue(for: mode))
    }
    
}
