import SwiftUI

extension Habit.Card {
    var weekView: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 9) {
                ForEach(0..<7, id: \.self) { dayIndex in
                    let dayDate = Calendar.current.date(byAdding: .day, value: dayIndex - 6, to: lastDay)!
                    let dayValue = weeklyValues.first { Calendar.current.isDate($0.date, inSameDayAs: dayDate) }
                    
                    HStack(spacing: 12) {
                        Text(dayDate.weekday)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.primary.opacity(dayIndex == 6 ? 0.8 : 0.4))
                            .lineLimit(1)
                            .frame(width: 10, height: 10)
                        
                        ProgressBar(
                            currentValue: dayValue?.currentValue ?? 0,
                            target: habit.target,
                            color: color,
                            axis: .horizontal,
                            width: 118,
                            height: 13,
                        )
                        .if(dayIndex == 6) {
                            $0.matchedGeometryEffect(id: "view", in: heroAnimation, anchor: .leading)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: config.dailyBarChartHeight)
            .transition(.blurReplace)
            .padding(.top, 18)
            .padding(.trailing, 4)
            
            Spacer()
            
            VStack(spacing: 4) {
                habitLabel
                    .matchedGeometryEffect(id: "habitLabel", in: heroAnimation)
                progressLabelCompact
            }
            .padding(.bottom, 10)
        }
    }
}
