import SwiftUI

extension Habit.Card {
    var dayView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                ProgressBar(
                    currentValue: lastDayValue?.currentValue ?? 0,
                    target: habit.target,
                    color: color,
                    axis: .vertical,
                    width: config.dailyBarChartWidth,
                    height: config.dailyBarChartHeight
                )
                .matchedGeometryEffect(id: "view", in: heroAnimation, anchor: .topLeading)
                
                VStack(spacing: 0) {
                    progressLabel
                        .frame(maxHeight: .infinity)
                    progressButton
                        .frame(width: 70, height: 70)
                }
            }
            .geometryGroup()
            .frame(height: config.dailyBarChartHeight)
            .transition(.blurReplace)
            .padding(.top, 20)
            
            Spacer()
            
            habitLabel
                .matchedGeometryEffect(id: "habitLabel", in: heroAnimation)
                .padding(.bottom, 20)
        }
    }
}
