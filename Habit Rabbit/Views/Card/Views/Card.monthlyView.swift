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
                                .fill(Habit.Card.cubeColor(for: cell.value, habit: cardManager.habit, cardColor: cardManager.color))
                                .strokeBorder(.tertiary, lineWidth: Habit.Card.cubeStrokeWidth(for: cell.value, habit: cardManager.habit, colorScheme: colorScheme))
                                .brightness(Habit.Card.cubeBrightness(for: cell.value, habit: cardManager.habit, colorScheme: colorScheme))
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

