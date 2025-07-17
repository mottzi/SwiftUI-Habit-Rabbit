import SwiftUI

extension Habit.Card {
    var backgroundView: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(.regularMaterial)
            .stroke(.quaternary, lineWidth: colorScheme == .dark ? 1 : 0.6)
            .background {
                backShadow
                orbView
            }
    }
    
    var backShadow: some View {
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
        
    var orbView: some View {
        Rectangle()
            .fill(color.gradient)
            .opacity(isCompleted ? (colorScheme == .dark ? 0.5 : 0.7) : 0)
            .offset(x: 0, y: 180)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(.rect(cornerRadius: 24))
    }
}
