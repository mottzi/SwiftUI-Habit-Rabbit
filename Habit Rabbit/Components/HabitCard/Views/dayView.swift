import SwiftUI

extension Habit.Card {
    var dayView: some View {
        HStack(spacing: 0) {
            ProgressBar(
                currentValue: currentValue,
                target: habit.target,
                color: color,
                axis: .vertical,
                kind: habit.kind,
                width: 50,
                height: contentHeight
            )
            .matchedGeometryEffect(id: "bar6", in: modeTransition, anchor: .topLeading)
            
            Spacer(minLength: 12)
            
            VStack(spacing: 0) {
                progressLabel
                    .frame(maxHeight: .infinity)
                progressButton
                    .frame(width: 70, height: 70)
            }
        }
        .frame(height: contentHeight)
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
}
