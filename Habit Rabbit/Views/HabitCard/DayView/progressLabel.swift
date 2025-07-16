import SwiftUI

extension Habit.Card {
    var progressLabel: some View {
        VStack(spacing: 2) {
            HStack(spacing: 2) {
                Text("\(currentValue)")
                    .foregroundStyle(.primary.opacity(colorScheme == .dark ? 1 : 0.8))
                +
                Text(" / ")
                    .foregroundStyle(.primary.opacity(0.6))
                +
                Text("\(target)")
                    .foregroundStyle(.primary.opacity(0.6))
            }
            .font(.title2)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .fontWeight(.semibold)
            .monospacedDigit()
            .contentTransition(.numericText())
            
            Text(unit.pluralized(count: currentValue))
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .fixedSize()
        }
        .padding(.horizontal, 2)
    }
}
