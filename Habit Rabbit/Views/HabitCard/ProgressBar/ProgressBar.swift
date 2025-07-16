import SwiftUI

extension Habit.Card {
    struct ProgressBar: View {
        @Environment(\.colorScheme) var colorScheme

        let currentValue: Int
        let target: Int
        let color: Color
        let width: CGFloat
        let height: CGFloat
        
        var body: some View {
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
                .frame(width: width, height: height)
        }
    }
}

extension Habit.Card.ProgressBar {
    var progress: CGFloat {
        guard target > 0 else { return 0 }
        return CGFloat(currentValue) / CGFloat(target)
    }
    
    var targetOffset: CGFloat {
        switch progress {
            case  ...0: height
            case 0..<1: height * (1 - progress) - 12
            case     1: 0
            case  1...: height * (1 - (1 / progress)) - 12
            default   : height
        }
    }
    
    var overflowOffset: CGFloat {
        progress > 1 ? 0 : targetOffset + width / 2
    }
    
    var targetBounceFiller: some View {
        Rectangle()
            .fill(color.gradient)
            .frame(height: height / 2 + width / 2)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .offset(y: width / 2)
    }
    
    var overflowFiller: some View {
        Capsule()
            .fill(color.gradient)
            .brightness(-0.035)
            .rotationEffect(.degrees(180))
            .offset(y: overflowOffset)
    }
}

extension Habit.Card {
    struct ProgressBar2: View {
        @Environment(\.colorScheme) var colorScheme
        
        let currentValue: Int
        let target: Int
        let color: Color
        let width: CGFloat
        let height: CGFloat
        
        var body: some View {
            Capsule()
                .fill(.quaternary)
                .overlay {
                    Capsule()
                        .fill(color)
                        .background { targetBounceFiller }
                        .offset(x: targetOffset)
                        .shadow(color: .black.opacity(0.07), radius: 2, x: 0, y: -2)
                        .background { overflowFiller }
                        .clipShape(.capsule)
                        .padding(1)
                }
                .frame(width: width, height: height)
        }
    }
}

extension Habit.Card.ProgressBar2 {
    var progress: CGFloat {
        guard target > 0 else { return 0 }
        return CGFloat(currentValue) / CGFloat(target)
    }
    
    var targetOffset: CGFloat {
        switch progress {
            case  ...0: -width
            case 0..<1: -width * (1 - progress) + 12
            case     1: 0
            case  1...: -width * (1 - (1 / progress)) + 12
            default   : -width
        }
    }
    
    var overflowOffset: CGFloat {
        progress > 1 ? 0 : targetOffset - height / 2
    }
    
    var targetBounceFiller: some View {
        Rectangle()
            .fill(color)
            .frame(width: width / 2 + height / 2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .offset(x: -height / 2)
    }
    
    var overflowFiller: some View {
        Capsule()
            .fill(color)
            .brightness(-0.2)
            .rotationEffect(.degrees(180))
            .offset(x: overflowOffset)
    }
}
