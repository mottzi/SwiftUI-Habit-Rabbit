import SwiftUI

extension Habit.Card {
    var habitLabel: some View {
        Label("\(manager.name)", systemImage: manager.icon)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundStyle(.primary)
            .lineLimit(1)
    }
}
