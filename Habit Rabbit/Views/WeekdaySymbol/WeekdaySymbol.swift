import SwiftUI

extension Habit {
    
    struct WeekdaySymbol: View {
        
        let symbol: String
        let color: Color
        
        init(symbol: String, color: Color) {
            self.symbol = symbol
            self.color = color
        }
        
        init(date: Date, color: Color) {
            self.symbol = date.weekdaySymbol
            self.color = color
        }
        
        var body: some View {
            Text(symbol)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(color)
                .lineLimit(1)
        }
        
    }
    
}
