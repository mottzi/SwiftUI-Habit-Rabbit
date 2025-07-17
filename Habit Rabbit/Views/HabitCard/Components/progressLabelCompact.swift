import SwiftUI

extension Habit.Card {
    var progressLabelCompact: some View {
        Text("\(currentValue) / \(target)")
            .foregroundStyle(.primary.opacity(0.5))
            .font(.subheadline)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .fontWeight(.medium)
            .monospacedDigit()
            .contentTransition(.numericText())
    }
}
