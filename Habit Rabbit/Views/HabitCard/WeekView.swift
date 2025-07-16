import SwiftUI

extension Habit.Card {
    var weekView: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(0..<7, id: \.self) { dayIndex in
                let dayDate = Calendar.current.date(byAdding: .day, value: dayIndex - 6, to: lastDay)!
                let dayValue = weeklyValues.first { Calendar.current.isDate($0.date, inSameDayAs: dayDate) }
                
                HStack(spacing: 12) {
                    Text(dayDate.weekday)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .frame(width: 10, height: 10)
                    
                    ProgressBar2(
                        currentValue: dayValue?.currentValue ?? Int.random(in: 0...habit.target * 2),
                        target: habit.target,
                        color: color,
                        width: 120,
                        height: 14,
                    )
                }
                .frame(height: 20)
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: config.dailyBarChartHeight)
        .padding(.horizontal, -10)
        .padding(.leading, -4)
        .padding(.top, -2)
    }
}
