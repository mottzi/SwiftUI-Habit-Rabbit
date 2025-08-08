import SwiftUI

extension Habit.Card {
    
    var weeklyView: some View {
        VStack(alignment: .leading, spacing: 9) {
            ForEach(cardManager.weeklyValues.enumerated, id: \.element.id) { index, value in
                HStack(spacing: 12) {
                    Habit.WeekdaySymbol(
                        date: value.date,
                        color: .primary.opacity(index == 6 ? 0.8 : 0.4)
                    )
                    .frame(width: 10, height: 13)
                    
                    Habit.ProgressBar(
                        value: value.currentValue,
                        target: cardManager.habit.target,
                        color: cardManager.color,
                        axis: .horizontal,
                        kind: cardManager.habit.kind,
                        mode: cardManager.mode,
                        width: 118,
                        height: 13,
                    )
                    .matchedGeometryEffect(id: "bar\(index)", in: modeTransition, anchor: .leading)
                }
                .geometryGroup()
                .frame(maxWidth: .infinity)
            }
        }
        .geometryGroup()
        .frame(height: Habit.Card.Manager.contentHeight)
        .padding(.top, 18)
        .padding(.trailing, 4)
    }
    
}
