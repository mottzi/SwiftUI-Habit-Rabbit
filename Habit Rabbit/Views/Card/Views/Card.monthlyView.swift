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
            .padding(.top, 4)
            .padding(.bottom, 2)
            
            VStack(spacing: 6) {
                ForEach(cardManager.monthlyValues, id: \.first?.date) { weekValues in
                    HStack(spacing: 6) {
                        ForEach(weekValues, id: \.date) { cell in                        
                            RoundedRectangle(cornerRadius: 4)
                                .fill(cubeColor(for: cell.value))
                                .strokeBorder(.tertiary, lineWidth: cubeStrokeWidth(for: cell.value))
                                .brightness(cubeBrightness(for: cell.value))
                                .frame(width: 16, height: 16)
                                .opacity(cell.value == nil ? 0 : 1)
                                .matchedGeometryEffect(id: "progress\(cell.date)", in: modeTransition)
                                .animation(.bouncy, value: cell.value?.currentValue)
                        }
                    }
                }
            }
            .compositingGroup()
            .geometryGroup()
            .frame(height: Habit.Card.Manager.cubesGridHeight)
            .frame(maxWidth: .infinity)
            .clipped()
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
