import SwiftUI

extension Habit.Card {
    
    var dailyView: some View {
        HStack(spacing: 0) {
            Habit.ProgressBar(
                currentValue: cardManager.currentValue(for: mode),
                target: cardManager.target,
                color: cardManager.color,
                axis: .vertical,
                kind: cardManager.kind,
                mode: cardManager.mode,
                width: 50,
                height: Habit.Card.Manager.contentHeight
            )
            .matchedGeometryEffect(id: "bar6", in: modeTransition, anchor: .topLeading)
            
            Spacer(minLength: 12)
            
            VStack(spacing: 0) {
                Habit.ProgressLabel(
                    currentValue: cardManager.currentValue(for: mode),
                    target: cardManager.habit.target,
                    unit: cardManager.unit
                )
                .animation(.bouncy, value: cardManager.currentValue(for: mode))
                .frame(maxHeight: .infinity)
                
                Habit.ProgressButton()
                    .frame(width: 70, height: 70)
            }
        }
        .frame(height: Habit.Card.Manager.contentHeight)
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
}


