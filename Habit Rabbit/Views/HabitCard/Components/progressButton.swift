import SwiftUI

extension Habit.Card {
    var progressButton: some View {
        Button {
            entry.currentDayValue.currentValue += 1
            feedbackTrigger.toggle()
        } label: {
            ZStack {
                Circle()
                    .fill(.quaternary)
                Circle()
                    .fill(color.gradient)
                    .padding(3)
                Image(systemName: "plus")
                    .font(.title)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.increase, trigger: feedbackTrigger)
    }
}
