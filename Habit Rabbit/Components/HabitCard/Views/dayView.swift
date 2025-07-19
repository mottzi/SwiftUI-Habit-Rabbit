import SwiftUI

extension Habit.Card {
    var dayView: some View {
        HStack(spacing: 12) {
            ProgressBar(
                currentValue: lastDayValue?.currentValue ?? 0,
                target: habit.target,
                color: color,
                axis: .vertical,
                width: 50,
                height: contentHeight
            )
            .matchedGeometryEffect(id: "bar6", in: modeTransition, anchor: .topLeading)
            
            VStack(spacing: 0) {
                progressLabel
                    .frame(maxHeight: .infinity)
                progressButton
                    .frame(width: 70, height: 70)
            }
        }
        .frame(height: contentHeight)
        .padding(.top, 20)
    }
}
