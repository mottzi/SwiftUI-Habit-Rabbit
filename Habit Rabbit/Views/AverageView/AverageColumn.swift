import SwiftUI

extension Habit.AverageView {

    struct AverageColumn: View {

        let title: String
        let currentValue: Int
        let target: Int
        let unit: String
        let color: Color
        let kind: Habit.Kind
        let mode: Habit.Card.Mode

        var body: some View {
            VStack(spacing: 10) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)

                Habit.ProgressBar(
                    currentValue: currentValue,
                    target: target,
                    color: color,
                    axis: .vertical,
                    kind: kind,
                    mode: mode,
                    width: 50,
                    height: Habit.Card.Manager.contentHeight
                )
                .frame(maxHeight: .infinity)

                Habit.ProgressLabel(
                    currentValue: currentValue,
                    target: target,
                    unit: unit
                )                
            }
            .frame(maxWidth: .infinity)
        }

    }

}
