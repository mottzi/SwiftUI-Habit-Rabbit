import SwiftUI

extension Habit.Card {
    var progressButton: some View {
        Button {
            lastDayValue?.currentValue += 1
        } label: {
            ZStack {
                Circle()
                    .fill(.quaternary)
                Circle()
                    .fill(color.gradient)
//                    .stroke(.quaternary, lineWidth: currentValue > target ? 8 : 0)
                    .clipShape(.capsule)
                    .padding(3)

                Image(systemName: habit.kind == .good ? "plus" : "minus")
                    .font(.title)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.increase, trigger: lastDayValue?.currentValue)
    }
}
