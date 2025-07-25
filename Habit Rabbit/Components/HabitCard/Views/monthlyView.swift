import SwiftUI

extension Habit.Card {
    var monthlyView: some View {
        VStack(spacing: 6) {
            dayLabels
                .padding(.bottom, 2)
            
            ForEach(monthlyGridValues.enumerated, id: \.offset) { rowIndex, weekValues in
                HStack(spacing: 6) {
                    ForEach(weekValues.enumerated, id: \.offset) { colIndex, dayValue in
                        let isBlankCell = dayValue == nil && rowIndex == 0 && colIndex < 5
                        let isLastRow = rowIndex == 4
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(cubeColor(for: dayValue))
                            .strokeBorder(.tertiary, lineWidth: cubeStrokeWidth(for: dayValue))
                            .brightness(cubeBrightness(for: dayValue))
                            .frame(width: 16, height: 16)
                            .opacity(isBlankCell ? 0 : 1) // hide the first 5 padding cells
                            .if(isLastRow) {
                                $0.matchedGeometryEffect(id: "bar\(colIndex)", in: modeTransition)
                            }
                            .animation(.bouncy, value: dayValue?.currentValue)
                    }
                }
                
            }
        }
        .geometryGroup()
        .frame(height: contentHeight)
        .padding(.top, 10)
    }
}

extension Habit.Card {
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
}

extension Habit.Card {
    func cubeColor(for value: Habit.Value?) -> AnyShapeStyle {
        guard let value else { return AnyShapeStyle(.quaternary) }
        
        let meetsTarget = habit.kind == .good
        ? value.currentValue >= habit.target
        : value.currentValue < habit.target
        
        return meetsTarget ? AnyShapeStyle(habit.color) : AnyShapeStyle(.quaternary)
    }
    
    func cubeBrightness(for value: Habit.Value?) -> Double {
        guard let value else { return 0 }
        let isDark = colorScheme == .dark
        let exceedsTarget = value.currentValue > habit.target
        let meetsTarget = value.currentValue == habit.target
        
        return switch (habit.kind, isDark, exceedsTarget, meetsTarget) {
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
        let exceedsTarget = value.currentValue > habit.target
        
        return switch (habit.kind, isDark, exceedsTarget) {
            case (.bad, true, true)  :  0.75  // exceeding bad habit in dark mode: medium stroke
            default                  :  0     // no stroke
        }
    }
}
