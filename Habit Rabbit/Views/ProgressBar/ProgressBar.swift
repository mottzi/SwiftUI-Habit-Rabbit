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
        
        private let inset: CGFloat = 3
        
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
                        .padding(axis == .vertical ? inset : 0)
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
        let dimension = axis == .vertical ? height : width
        
        let base: CGFloat = switch (kind, axis) {
            case (.good, .vertical)   :  dimension - inset * 2    // fills upward
            case (.good, .horizontal) : -dimension                // fills rightward
            case (.bad, .vertical)    :  dimension - inset * 2    // depletes downward
            case (.bad, .horizontal)  : -dimension                // depletes leftward
        }
        
        return switch kind {
            case .good:
                switch progress {
                    case  ...0: base
                    case 0..<1: base * (1 - compensate(progress))
                    case  1...: 0
                    default   : base
                }
            case .bad:
                switch progress {
                    case  ...0: 0
                    case 0..<1: base * (1 - compensate(1 - progress))
                    case  1...: base
                    default   : 0
                }
        }
    }
    
}

extension Habit.ProgressBar {
    
    // boosts mid-range values to compensate the visual shortening from rounded capsule caps
    func compensate(_ progress: CGFloat) -> CGFloat {
        let clamped = max(0, min(1, progress))
        let lift = min(0.06, 0.04 + 0.6 * curvature)
        let bump = clamped * (1 - clamped)
        let power: CGFloat = 2
        let peak = pow(0.25, power)
        let scale = lift / peak
        let boost = scale * pow(bump, power)
        return max(0, min(1, clamped + boost))
    }
    
    // bar thickness relative to its usable track length
    var curvature: CGFloat {
        let isVertical = axis == .vertical
        let thickness = isVertical ? width : height
        let length = isVertical ? height : width
        let inset = isVertical ? inset : 0
        let track = max(1, length - inset * 2)
        return min(1, thickness / track)
    }
    
}

extension Habit.ProgressBar {
    
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
    
    private var isDark: Bool { colorScheme == .dark }
    
    private var isDaily: Bool { mode == .daily }
    
    private var exceedsTarget: Bool { value > target }
    
}
