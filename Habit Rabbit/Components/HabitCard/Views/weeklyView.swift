import SwiftUI

extension Habit.Card {
    var weeklyView: some View {
        VStack(alignment: .leading, spacing: 9) {
            ForEach(weeklyValues.enumerated, id: \.element.id) { index, value in
                HStack(spacing: 12) {
                    dayLetter(
                        for: value.date,
                        color: .primary.opacity(index == 6 ? 0.8 : 0.4)
                    )
                    .frame(width: 10, height: 13)
                    
                    ProgressBar(
                        currentValue: value.currentValue,
                        target: habit.target,
                        color: color,
                        axis: .horizontal,
                        kind: habit.kind,
                        mode: mode,
                        width: 118,
                        height: 13,
                    )
                    .matchedGeometryEffect(id: "bar\(index)", in: modeTransition)
                }
                .geometryGroup()
                .frame(maxWidth: .infinity)
            }
        }
        .geometryGroup()
        .frame(height: contentHeight)
        .padding(.top, 18)
        .padding(.trailing, 4)
    }
}
