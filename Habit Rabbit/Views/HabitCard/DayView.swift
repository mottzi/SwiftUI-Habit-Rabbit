import SwiftUI

extension Habit.Card {
    var dayView: some View {
        HStack(spacing: 12) {
            progressChart
                .frame(width: config.barChartWidth)
            VStack(spacing: 0) {
                progressLabel
                    .frame(maxHeight: .infinity)
                progressButton
                    .frame(width: 70, height: 70)
            }
        }
        .geometryGroup()
        .frame(height: config.barChartHeight)
    }
}
