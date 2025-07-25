import SwiftUI

extension Habit.Card {
    var progressButton: some View {
        Button {
            lastDayValue?.currentValue += 1
        } label: {
            ZStack {
                Circle()
                    .fill(.quaternary)
                Circle()
                    .fill(color.gradient)
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
        .sensoryFeedback(.increase, trigger: lastDayValue?.currentValue)
    }
    
    var buttonBrightness: Double {
        if habit.kind == .good {
            return currentValue > target ? (colorScheme == .dark ? 0.1 : -0.1) : (colorScheme == .dark ? -0.1 : 0.1)
        } else {
            return 0
        }
    }
}
