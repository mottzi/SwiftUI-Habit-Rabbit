import SwiftUI

extension Habit.Card {
    var progressLabel: some View {
        VStack(spacing: 2) {
            VStack {
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
                .fontWeight(.semibold)
                .monospacedDigit()
                .contentTransition(.numericText())
            }
            
            Text(unit.pluralized(count: displayValue))
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .minimumScaleFactor(0.7)
        .lineLimit(1)
        .padding(.horizontal, 2)
        .animation(.bouncy, value: displayValue)
    }
}
