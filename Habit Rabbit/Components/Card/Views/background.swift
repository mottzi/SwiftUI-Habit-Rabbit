import SwiftUI

extension Habit.Card {
    
    var background: some View {
        Habit.CardSurface {
            colorEffect
        }
    }
    
    var colorEffect: some View {
        Rectangle()
            .fill(cardManager.color.gradient)
            .opacity(cardManager.isCompleted(for: mode) ? (colorScheme == .dark ? 0.5 : 0.7) : 0)
            .offset(x: 0, y: 180)
            .clipShape(.rect(cornerRadius: 24))
            .animation(.bouncy, value: cardManager.isCompleted(for: mode))
    }
    
}
