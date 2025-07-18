import SwiftUI

#Preview {
    let cards = Habit.examples.enumerated.map { index, habit in
        Habit.Card(habit: habit, day: .now, mode: Habit.Card.Mode.allCases.randomElement()!, index: index)
    }
    
    VStack(spacing: 16) {
        HStack(spacing: 16) {
            cards[0]
            cards[1]
        }
        HStack(spacing: 16) {
            cards[2]
            cards[3]
        }
        HStack(spacing: 16) {
            cards[4]
            cards[5]
        }
    }
    .padding(16)
}
import SwiftUI

extension Habit.Card {
    var monthView: some View {
        VStack(spacing: 0) {
            VStack(spacing: 6) {
                // Weekday header row
                HStack(spacing: 6) {
                    ForEach(0..<7, id: \.self) { dayOfWeek in
                        let weekdayDate = Calendar.current.date(byAdding: .day, value: dayOfWeek - 6, to: lastDay)!
                        Text(weekdayDate.weekday.prefix(1))
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.primary.opacity(0.4))
                            .frame(width: 16, height: 12)
                    }
                }
                .padding(.bottom, 6)
                
                let paddedValues = Array(repeating: nil, count: 5) + monthlyValues.map { $0 }
                
                ForEach(0..<5, id: \.self) { rowIndex in
                    HStack(spacing: 6) {
                        ForEach(0..<7, id: \.self) { colIndex in
                            let index = rowIndex * 7 + colIndex
                            let dayValue = paddedValues[safe: index] ?? nil
                            let isLastDay = index == 34 // Last position in 5x7 grid
                            
                            if index >= 5 {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(dayValue?.currentValue ?? 0 > 0 ? color : Color(white: colorScheme == .dark ? 0.3 : 0.8))
                                    .brightness(brightness(for: dayValue))
                                    .frame(width: 16, height: 16)
                                    .if(isLastDay) {
                                        $0.matchedGeometryEffect(id: "view", in: heroAnimation, anchor: .center)
                                    }
                            }
                            else {
                                Color.clear.frame(width: 16, height: 16)
                            }
                        }
                    }
                }
            }
            .frame(height: config.dailyBarChartHeight)
            .transition(.blurReplace)
            .padding(.top, 10)
            
            Spacer()
            
            VStack(spacing: 5) {
                habitLabel
                    .matchedGeometryEffect(id: "habitLabel", in: heroAnimation)
                progressLabelCompact
            }
            .padding(.bottom, 10)
        }
    }
    
    private func brightness(for value: Habit.Value?) -> CGFloat {
        guard let value else { return 0 }
        
        if value.currentValue > habit.target {
            return colorScheme == .light ? -0.125 : -0.200
        }
        
        return 0
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
