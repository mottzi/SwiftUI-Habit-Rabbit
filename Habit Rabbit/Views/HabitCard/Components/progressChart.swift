import SwiftUI

extension Habit.Card {
    var progressChart: some View {
        Capsule()
            .fill(.quaternary)
            .overlay {
                Capsule()
                    .fill(color.gradient)
                    .background { targetBounceFiller }
                    .offset(y: targetOffset)
                    .shadow(color: .black.opacity(0.07), radius: 2, x: 0, y: -2)
                    .background { overflowFiller }
                    .clipShape(.capsule)
                    .padding(3)
            }
    }
}

extension Habit.Card {
    var targetOffset: CGFloat {
        switch progress {
            case  ...0: barChartHeight
            case 0..<1: barChartHeight * (1 - progress) - 12
            case     1: 0
            case  1...: barChartHeight * (1 - (1 / progress)) - 12
            default   : barChartHeight
        }
    }
    
    var overflowOffset: CGFloat {
        progress > 1 ? 0 : targetOffset + barChartWidth / 2
    }
    
    var glowColor: Color {
        switch colorScheme {
            case .light: color.opacity(0.1)
            case .dark: color.opacity(0.05)
            @unknown default: color.opacity(0.1)
        }
    }
}

extension Habit.Card {
    var targetBounceFiller: some View {
        Rectangle()
            .fill(color.gradient)
            .frame(height: barChartHeight / 2 + barChartWidth / 2)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .offset(y: barChartWidth / 2)
    }
    
    var overflowFiller: some View {
        Capsule()
            .fill(color.gradient)
            .brightness(-0.035)
            .rotationEffect(.degrees(180))
            .offset(y: overflowOffset)
    }
}
