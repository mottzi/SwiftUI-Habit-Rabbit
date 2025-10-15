import SwiftUI

extension Habit.Card {
    
    @ViewBuilder
    var contextMenuButtons: some View {
        Button("Edit", systemImage: "pencil") {
            editingHabit = cardManager.habit
        }
        
        #if DEBUG
        Button("Randomize", systemImage: "sparkles") {
            cardManager.randomizeDailyValue()
        }
        
        Button("Randomize Name", systemImage: "characters.uppercase") {
            cardManager.randomizeName()
        }
        
        Button("Reset", systemImage: "arrow.counterclockwise") {
            cardManager.dailyValue?.currentValue = 0
        }
        #endif
        
        Button("Delete", systemImage: "trash", role: .destructive) {
            deleteWithAnimation()
        }
    }
    
}
