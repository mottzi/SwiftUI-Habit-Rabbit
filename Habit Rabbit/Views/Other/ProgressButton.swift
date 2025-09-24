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
        let isDark = colorScheme == .dark
        let exceedsTarget = cardManager.currentValue(for: mode) > cardManager.habit.target
        
        return switch (cardManager.habit.kind, isDark, exceedsTarget) {
            case (.good, true, true)   :  0.1   // exceeding good habit in dark mode: brighter
            case (.good, true, false)  : -0.1   // not exceeding good habit in dark mode: darker
            case (.good, false, true)  : -0.1   // exceeding good habit in light mode: darker
            case (.good, false, false) :  0.1   // not exceeding good habit in light mode: brighter
            case (.bad, _, _)          :  0     // bad habits: no adjustment
        }
    }
    
}
