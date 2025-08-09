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
    
    // Ratio of the capsule's end-radius to the travel length. Higher ratio ⇒ stronger visual rounding effect.
    var curvature: CGFloat {
        let dimension = axis == .vertical ? height : width
        let inset = axis == .vertical ? 3.0 : 0.0
        let length = max(1, dimension - inset * 2)
        let thickness = axis == .vertical ? width : height
        return min(1, thickness / length)
    }
    
    // Perceptual compensation for rounded capsule ends.
    // - Keeps bounds: f(0) = 0, f(1) = 1
    // - Monotonic and with unit slope at the ends to avoid "nerfed" motion near 0 or 1
    // - Symmetric, narrow bump centered at 0.5 increases apparent mid-range progress
    func compensate(_ p: CGFloat) -> CGFloat {
        let clamped = max(0, min(1, p))
        let strength = 0.9 * curvature          // tuned strength, scales with curvature
        let bump = clamped * (1 - clamped)      // 0 at edges, max at 0.5
        let adjustment = strength * bump * bump * bump // higher-order bump → zero slope for bump at edges; f'(0)=f'(1)=1
        return max(0, min(1, clamped + adjustment))
    }
    
    var offset: CGFloat {
        let dimension = axis == .vertical ? height : width
        let inset = axis == .vertical ? 3.0 : 0.0
        
        let base: CGFloat = switch (kind, axis) {
            case (.good, .vertical): dimension - inset * 2  // fills upward
            case (.good, .horizontal): -dimension           // fills rightward
            case (.bad, .vertical): dimension - inset * 2   // depletes downward
            case (.bad, .horizontal): -dimension            // depletes leftward
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
                    case 0..<1: base * compensate(progress)
                    case  1...: base
                    default   : 0
                }
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
