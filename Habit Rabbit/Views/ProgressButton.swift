import SwiftUI

extension Habit {
    
    struct ProgressButton: View {
        
        @Environment(\.colorScheme) private var colorScheme
        @Environment(\.cardMode) var cardMode
        
        @Environment(Habit.Card.Manager.self) private var cardManager
        
        var mode: Habit.Card.Mode {
            cardMode ?? cardManager.mode
        }
        
        var body: some View {
            Button {
                cardManager.dailyValue?.currentValue += 1
            } label: {
                ZStack {
                    Circle()
                        .fill(.quaternary)
                    Circle()
                        .fill(cardManager.color.gradient)
                        .brightness(buttonBrightness)
                        .clipShape(.capsule)
                        .padding(3)
                        .animation(.default, value: buttonBrightness)
                    
                    Image(systemName: "plus")
                        .font(.title)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.increase, trigger: cardManager.dailyValue?.currentValue)
        }
        
    }
    
}

extension Habit.ProgressButton {
    
    var buttonBrightness: Double {
        if cardManager.habit.kind == .good {
            return cardManager.currentValue(for: mode) > cardManager.habit.target ? (colorScheme == .dark ? 0.1 : -0.1) : (colorScheme == .dark ? -0.1 : 0.1)
        } else {
            return 0
        }
    }
    
}
