import SwiftUI

extension Habit.Card {
    
    var monthlyView: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                ForEach(dashboardManager.weekdaySymbols.enumerated, id: \.offset) { index, symbol in
                    Habit.WeekdaySymbol(
                        symbol: symbol,
                        color: weekdaySymbolStyle(for: index)
                    )
                    .frame(width: 16, height: 16)
                }
            }
            .padding(.bottom, 2)
            
            ForEach(cardManager.monthlyValues.enumerated, id: \.offset) { rowIndex, weekValues in
                HStack(spacing: 6) {
                    ForEach(weekValues.enumerated, id: \.offset) { colIndex, dayValue in
                        let isBlankCell = dayValue == nil
                        let matchedId = matchedBarId(for: dayValue?.date)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(cubeColor(for: dayValue))
                            .strokeBorder(.tertiary, lineWidth: cubeStrokeWidth(for: dayValue))
                            .brightness(cubeBrightness(for: dayValue))
                            .frame(width: 16, height: 16)
                            .opacity(isBlankCell ? 0 : 1)
                            .if(matchedId != nil) { 
                                $0.matchedGeometryEffect(id: matchedId!, in: modeTransition) 
                            }
                            .animation(.bouncy, value: dayValue?.currentValue)
                    }
                }
                
            }
        }
        .geometryGroup()
        .frame(height: Habit.Card.Manager.contentHeight)
        .padding(.top, 10)
    }
    
}

extension Habit.Card {
    
    private func weekdaySymbolStyle(for index: Int) -> Color {
        .primary.opacity(index == dashboardManager.lastDayIndex ? 0.8 : 0.4)
    }
    
    func matchedBarId(for date: Date?) -> String? {
        guard let date else { return nil }
        let days = Calendar.current.dateComponents([.day], from: date, to: cardManager.lastDay).day!
        guard (0...6).contains(days) else { return nil }
        return "bar\(6 - days)"
    }

}

extension Habit.Card {
    
    func cubeColor(for value: Habit.Value?) -> AnyShapeStyle {
        guard let value else {
            if cardManager.kind == .good {
                return AnyShapeStyle(.quaternary)
            } else {
                return AnyShapeStyle(cardManager.color)
            }
        }
        
        let meetsTarget = cardManager.habit.kind == .good
        ? value.currentValue >= cardManager.habit.target
        : value.currentValue < cardManager.habit.target
        
        return meetsTarget ? AnyShapeStyle(cardManager.color) : AnyShapeStyle(.quaternary)
    }
    
    func cubeBrightness(for value: Habit.Value?) -> Double {
        guard let value else { return 0 }
        let isDark = colorScheme == .dark
        let exceedsTarget = value.currentValue > cardManager.habit.target
        let meetsTarget = value.currentValue == cardManager.habit.target
        
        return switch (cardManager.habit.kind, isDark, exceedsTarget, meetsTarget) {
            case (.good, true, true, _)   :  0.1   // exceeding good habit in dark mode: brighter
            case (.good, true, false, _)  : -0.1   // not exceeding good habit in dark mode: darker
            case (.good, false, true, _)  : -0.1   // exceeding good habit in light mode: darker
            case (.good, false, false, _) :  0.1   // not exceeding good habit target in light mode: brighter
            case (.bad, _, false, false)  :  0     // below bad habit: no adjustment
            case (.bad, _, false, true)   :  0.2   // meeting bad habit: brighter
            case (.bad, true, true, _)    : -0.6   // exceeding bad habit in dark mode: much darker
            case (.bad, false, true, _)   : -0.8   // exceeding bad habit in light mode: darker
        }
    }
    
    func cubeStrokeWidth(for value: Habit.Value?) -> Double {
        guard let value else { return 0 }
        let isDark = colorScheme == .dark
        let exceedsTarget = value.currentValue > cardManager.habit.target
        
        return switch (cardManager.habit.kind, isDark, exceedsTarget) {
            case (.bad, true, true)  :  0.75  // exceeding bad habit in dark mode: medium stroke
            default                  :  0     // no stroke
        }
    }
    
}
