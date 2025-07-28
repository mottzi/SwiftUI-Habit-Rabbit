import SwiftUI

extension Habit.Card {
    var dailyView: some View {
        HStack(spacing: 0) {
            ProgressBar(
                currentValue: manager.currentValue,
                target: manager.habit.target,
                color: manager.color,
                axis: .vertical,
                kind: manager.habit.kind,
                mode: manager.mode,
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
