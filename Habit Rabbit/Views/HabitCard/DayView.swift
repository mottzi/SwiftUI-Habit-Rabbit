import SwiftUI

extension Habit.Card {
    var dayView: some View {
        HStack(spacing: 12) {
            ProgressBar(
                currentValue: lastDayValue?.currentValue ?? 0,
                target: habit.target,
                color: color,
                width: config.dailyBarChartWidth,
                height: config.dailyBarChartHeight
            )
            
            VStack(spacing: 0) {
                progressLabel
                    .frame(maxHeight: .infinity)
                progressButton
                    .frame(width: 70, height: 70)
            }
        }
        .geometryGroup()
        .frame(height: config.dailyBarChartHeight)
    }
}
