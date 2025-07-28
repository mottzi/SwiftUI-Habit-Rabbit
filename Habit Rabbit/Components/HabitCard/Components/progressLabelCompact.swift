import SwiftUI

extension Habit.Card {
    var progressLabelCompact: some View {
        Text("\(manager.currentValue) / \(manager.target)")
            .foregroundStyle(.primary.opacity(0.5))
            .font(.subheadline)
            .fontWeight(.medium)
            .monospacedDigit()
            .fixedSize()
            .contentTransition(.numericText())
    }
}
