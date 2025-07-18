import SwiftUI

#Preview {
    let cards = Habit.examples.enumerated.map { index, habit in
        Habit.Card(habit: habit, lastDay: .now, mode: Habit.Card.Mode.allCases.randomElement()!, index: index)
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
    var dayLabels: some View {
        HStack(spacing: 6) {
            ForEach(weeklyValues, id: \.id) { value in
                dayLetter(
                    for: value.date,
                    color: .primary.opacity(0.4)
                )
                .frame(width: 16, height: 16)
            }
        }
    }
    var monthView: some View {
        VStack(spacing: 0) {
            VStack(spacing: 6) {
                dayLabels
                    .padding(.bottom, 2)
                
                // add 5 blank days so the first row is a complete week
                let paddedValues = Array(repeating: nil, count: 5) + monthlyValues.map { $0 }
                
                ForEach(0..<5, id: \.self) { rowIndex in
                    HStack(spacing: 6) {
                        ForEach(0..<7, id: \.self) { colIndex in
                            let index = rowIndex * 7 + colIndex
                            let dayValue = paddedValues[safe: index] ?? nil
                            let isLastDay = index == 34 // Last position in 5x7 grid
                            
                            // Check if this is one of the last 7 rectangles (last row)
                            let isLastWeek = rowIndex == 4//index >= 28 && index <= 34
                            let barIndex = index - 28 // Convert to 0-6 range for last week
                            
                            if index >= 5 {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(dayValue?.currentValue ?? 0 > 0 ? color : Color(white: colorScheme == .dark ? 0.3 : 0.8))
                                    .brightness(brightness(for: dayValue))
                                    .frame(width: 16, height: 16)
                                    .if(isLastDay) {
                                        $0.matchedGeometryEffect(id: "view", in: modeTransition, anchor: .center)
                                    }
                                    .if(isLastWeek && !isLastDay) {
                                        $0.matchedGeometryEffect(id: "bar\(barIndex)", in: modeTransition, anchor: .center)
                                    }
                            }
                            else {
                                Color.clear.frame(width: 16, height: 16)
                            }
                        }
                    }
                }
            }
            .frame(height: contentHeight)
            .transition(.blurReplace)
            .padding(.top, 10)
            
            Spacer()
            
            VStack(spacing: 5) {
                habitLabel
                    .matchedGeometryEffect(id: "habitLabel", in: modeTransition)
                progressLabelCompact
                    .matchedGeometryEffect(id: "progressLabel", in: modeTransition)
            }
            .padding(.bottom, 14)
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
