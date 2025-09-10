import SwiftUI

extension Habit {

    struct ProgressLabel: View {

        @Environment(\.colorScheme) var colorScheme

        let value: Int
        let target: Int
        let unit: String

        var body: some View {
            VStack(spacing: 2) {
                VStack {
                    (
                        Text(verbatim: "\(value)")
                            .foregroundStyle(.primary.opacity(colorScheme == .dark ? 1 : 0.8))
                        +
                        Text(verbatim: " / ")
                            .foregroundStyle(.primary.opacity(0.6))
                        +
                        Text(verbatim: "\(target)")
                            .foregroundStyle(.primary.opacity(0.6))
                    )
                    .font(.title2)
                    .fontWeight(.semibold)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                }
                Text(verbatim: unit.pluralized(count: target))
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
