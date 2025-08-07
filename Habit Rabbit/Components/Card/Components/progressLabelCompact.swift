import SwiftUI

extension Habit.Card {
    
    var progressLabelCompact: some View {
        (
            Text("\(cardManager.currentValue(for: mode))")
                .foregroundStyle(.primary.opacity(colorScheme == .dark ? 1 : 0.8))
            +
            Text(" / ")
                .foregroundStyle(.primary.opacity(0.6))
            +
            Text("\(cardManager.currentTarget(for: mode))")
                .foregroundStyle(.primary.opacity(0.6))
        )
        .font(.subheadline)
        .fontWeight(.semibold)
        .monospacedDigit()
        .contentTransition(.numericText())
    }
    
}
