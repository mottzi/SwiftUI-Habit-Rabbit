import SwiftUI

extension Habit.Card {
    var monthView: some View {
        VStack(spacing: 6) {
            dayLabels
                .padding(.bottom, 2)
            
            ForEach(monthlyGridValues.enumerated, id: \.offset) { rowIndex, weekValues in
                HStack(spacing: 6) {
                    ForEach(weekValues.enumerated, id: \.offset) { colIndex, dayValue in
                        let isBlankPaddingCell = dayValue == nil && rowIndex == 0 && colIndex < 5
                        let isLastWeek = rowIndex == 4 // Last row (week)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(dayValue?.currentValue ?? 0 > 0 ? color : Color(white: colorScheme == .dark ? 0.3 : 0.8))
                            .brightness(brightness(for: dayValue))
                            .frame(width: 16, height: 16)
                            .opacity(isBlankPaddingCell ? 0 : 1) // Only hide the first 5 padding cells
                            .if(isLastWeek) {
                                $0.matchedGeometryEffect(id: "bar\(colIndex)", in: modeTransition)
                            }
                    }
                }
            }
        }
        .geometryGroup()
        .frame(height: contentHeight)
        .padding(.top, 10)
    }
    
    // Clean computed property like weeklyValues - creates 5x7 grid with today at bottom-right
    var monthlyGridValues: [[Habit.Value?]] {
        let totalCells = 5 * 7
        let paddingCount = totalCells - monthlyValues.count
        
        var paddedValues: [Habit.Value?] = Array(repeating: nil, count: paddingCount)
        paddedValues.append(contentsOf: monthlyValues.map { $0 as Habit.Value? })
        
        // Convert flat array to 5x7 grid
        return stride(from: 0, to: paddedValues.count, by: 7).map { startIndex in
            Array(paddedValues[startIndex..<min(startIndex + 7, paddedValues.count)])
        }
    }
    
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
    
    func brightness(for value: Habit.Value?) -> CGFloat {
        guard let value else { return 0 }
        
        if value.currentValue > habit.target {
            return colorScheme == .light ? -0.125 : -0.200
        }
        
        return 0
    }
}
