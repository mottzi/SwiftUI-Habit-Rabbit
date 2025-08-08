import SwiftUI

extension Habit.AverageView {

    struct AverageColumn: View {

        let title: String
        let value: Int
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
                    value: value,
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
                    value: value,
                    target: target,
                    unit: unit
                )                
            }
            .frame(maxWidth: .infinity)
        }

    }

}
