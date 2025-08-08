import SwiftUI

extension Habit {
    
    struct ProgressBar: View {
        
        @Environment(\.colorScheme) var colorScheme
        
        let value: Int
        let target: Int
        let color: Color
        let axis: Axis
        let kind: Habit.Kind
        let mode: Habit.Card.Mode
        let width: CGFloat
        let height: CGFloat
        
        var body: some View {
            Capsule()
                .fill(.quaternary)
                .strokeBorder(.quaternary, lineWidth: trackStrokeWidth)
                .brightness(trackBrightness)
                .overlay {
                    Capsule()
                        .fill(color.gradient)
                        .brightness(colorBrightness)
                        .offset(
                            x: axis == .horizontal ? offset : 0,
                            y: axis == .vertical ? offset : 0
                        )
                        .shadow(color: .black.opacity(0.07), radius: 2, x: 0, y: -2)
                        .clipShape(.capsule)
                        .padding(axis == .vertical ? 3 : 0)
                }
                .geometryGroup()
                .frame(width: width, height: height)
                .fixedSize()
                .animation(.bouncy, value: value)
        }
    }
    
}

extension Habit.ProgressBar {
    
    var progress: CGFloat {
        guard target > 0 else { return 0 }
        return CGFloat(value) / CGFloat(target)
    }
    
    var offset: CGFloat {
        let max = axis == .vertical ? height : width
        let inset = axis == .vertical ? 3.0 : 0.0
        let baseOffset: CGFloat = switch (kind, axis) {
            case (.good, .vertical): max - inset * 2  // fills upward
            case (.good, .horizontal): -max   // fills rightward
            case (.bad, .vertical): max - inset * 2   // depletes downward
            case (.bad, .horizontal): -max    // depletes leftward
        }
        
        return switch progress {
            // no progress -> good: start hidden, bad: start full
            case ...0: kind == .good ? baseOffset : 0
            // partial progress -> good: fill up, bad: deplete down
            case 0..<1: baseOffset * (kind == .good ? 1 - progress : progress)
            // target reached -> good: fully visible, Bad: fully hidden
            case 1...: kind == .good ? 0 : baseOffset
            // edge cases
            default: kind == .good ? baseOffset : 0
        }
    }
    
}

extension Habit.ProgressBar {
    
    var isDark: Bool { colorScheme == .dark }
    
    var isDaily: Bool { mode == .daily }
    
    var exceedsTarget: Bool { value > target }
    
    var colorBrightness: Double {
        switch (kind, isDark, exceedsTarget) {
            case (.bad, _, _)          :  0     // bad habit: no adjustment
            case (.good, true, true)   :  0.1   // exceeding good habit in dark mode: brighter color
            case (.good, true, false)  : -0.1   // non-exceeding good habit in dark mode: darker color
            case (.good, false, true)  : -0.1   // exceeding good habit in light mode: darker color
            case (.good, false, false) :  0.1   // non-exceeding good habit in light mode: brighter color
        }
    }
    
    var trackBrightness: Double {
        switch (kind, isDark, exceedsTarget) {
            case (.good, _, _)       :  0.2   // good habits: no adjustment
            case (.bad, _, false)    :  0.2   // non-exceeding bad habit in dark mode: no adjustment
            case (.bad, true, true)  : -0.6   // exceeding bad habit in dark mode: much darker
            case (.bad, false, true) : -0.5   // exceeding bad habit in light mode: darker
        }
    }
    
    var trackStrokeWidth: Double {
        switch (kind, isDark, exceedsTarget, isDaily) {
            case (.good, _, _, _)          :  0     // good habits: no stroke
            case (.bad, _, false, _)       :  0     // non-exceeding bad habit: no stroke
            case (.bad, false, true, _)    :  0     // exceeding bad habit in light mode: no stroke
            case (.bad, true, true, true)  :  1.5   // exceeding bad habit in daily dark mode: thick stroke
            case (.bad, true, true, false) :  0.75  // exceeding bad habit in other dark mode: medium stroke
        }
    }
    
}
