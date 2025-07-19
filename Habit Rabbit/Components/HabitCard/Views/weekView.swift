import SwiftUI

extension Habit.Card {
    var weekView: some View {
        VStack(spacing: 0) {
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
                            width: 118,
                            height: 13,
                        )
                        .matchedGeometryEffect(id: "bar\(index)", in: modeTransition)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: contentHeight)
            .transition(.blurReplace)
            .padding(.top, 18)
            .padding(.trailing, 4)
            
            Spacer()
            
            VStack(spacing: 4) {
                habitLabel
                    .matchedGeometryEffect(id: "habitLabel", in: modeTransition)
                progressLabelCompact
                    .matchedGeometryEffect(id: "progressLabel", in: modeTransition)
            }
            .padding(.bottom, 10)
        }
    }
}
