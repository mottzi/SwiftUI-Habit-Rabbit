import SwiftUI

extension Habit.Card {
    
    var habitLabel: some View {
        Label("\(cardManager.name)", systemImage: cardManager.icon)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundStyle(.primary)
            .lineLimit(1)
    }
    
}
