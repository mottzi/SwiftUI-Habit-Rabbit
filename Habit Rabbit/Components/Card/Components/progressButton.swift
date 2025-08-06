import SwiftUI

extension Habit.Card {
    
    var progressButton: some View {
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
    
    var buttonBrightness: Double {
        if cardManager.habit.kind == .good {
            return cardManager.currentValue > cardManager.habit.target ? (colorScheme == .dark ? 0.1 : -0.1) : (colorScheme == .dark ? -0.1 : 0.1)
        } else {
            return 0
        }
    }
    
}
