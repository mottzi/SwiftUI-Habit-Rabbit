import SwiftUI

extension Habit.Card {
    var progressButton: some View {
        Button {
            todayValue?.currentValue += 1
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
        .sensoryFeedback(.increase, trigger: todayValue?.currentValue)
    }
}
