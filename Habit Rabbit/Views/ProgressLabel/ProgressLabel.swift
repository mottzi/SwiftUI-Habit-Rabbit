import SwiftUI

extension Habit {

    struct ProgressLabel: View {

        @Environment(\.colorScheme) var colorScheme

        let currentValue: Int
        let target: Int
        let unit: String

        var body: some View {
            VStack(spacing: 2) {
                VStack {
                    (
                        Text("\(currentValue)")
                            .foregroundStyle(.primary.opacity(colorScheme == .dark ? 1 : 0.8))
                        +
                        Text(" / ")
                            .foregroundStyle(.primary.opacity(0.6))
                        +
                        Text("\(target)")
                            .foregroundStyle(.primary.opacity(0.6))
                    )
                    .font(.title2)
                    .fontWeight(.semibold)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                }
                Text(unit.pluralized(count: target))
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .minimumScaleFactor(0.7)
            .lineLimit(1)
            .padding(.horizontal, 2)
        }

    }
    
}
