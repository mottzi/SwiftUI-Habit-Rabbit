import SwiftUI

extension Habit.Card {
    
    func dayLetter(for date: Date, color: Color) -> some View {
        Text(date.weekday)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundStyle(color)
            .lineLimit(1)
    }
    
    func dayLetter(symbol: String, color: Color) -> some View {
        Text(symbol)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundStyle(color)
            .lineLimit(1)
    }
    
}
