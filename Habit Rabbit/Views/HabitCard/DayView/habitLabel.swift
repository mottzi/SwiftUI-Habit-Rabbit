import SwiftUI

extension Habit.Card {
    var habitLabel: some View {
        Label("\(name)", systemImage: icon)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundStyle(.primary)
            .lineLimit(1)
            .frame(maxHeight: .infinity, alignment: .bottom)
    }
}
