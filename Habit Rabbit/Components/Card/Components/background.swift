import SwiftUI

extension Habit.Card {
    
    var background: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(.regularMaterial)
            .stroke(.quaternary, lineWidth: colorScheme == .dark ? 1 : 0.6)
            .background {
                shadow
                colorEffect
            }
    }
    
    var shadow: some View {
        ZStack {
            if colorScheme == .light {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.black.opacity(0.09))
                    .blur(radius: 10)
                    .offset(x: 0, y: 4)
                
                RoundedRectangle(cornerRadius: 24)
                    .fill(.black.opacity(0.05))
                    .blur(radius: 4)
                    .offset(x: 0, y: 2)
                
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(uiColor: .systemBackground))
            }
        }
    }
        
    var colorEffect: some View {
        Rectangle()
            .fill(cardManager.color.gradient)
            .opacity(cardManager.isCompleted ? (colorScheme == .dark ? 0.5 : 0.7) : 0)
            .offset(x: 0, y: 180)
            .clipShape(.rect(cornerRadius: 24))
            .animation(.bouncy, value: cardManager.isCompleted)
    }
    
}
