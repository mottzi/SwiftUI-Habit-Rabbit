import SwiftUI

extension Habit {
    
    struct WeekdaySymbol: View {
        
        let symbol: String
        let color: Color
        
        var body: some View {
            Text(symbol)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(color)
                .lineLimit(1)
        }
        
    }
    
}
