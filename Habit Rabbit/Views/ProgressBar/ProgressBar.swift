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
        
        let inset: CGFloat = 3
        
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
                    case 0..<1: base * compensateMirrored(progress)
                    case  1...: base
                    default   : 0
                }
        }
    }
    
}

extension Habit.ProgressBar {
    
    // Ratio of the capsule's end-radius to the travel length. Higher ratio ⇒ stronger visual rounding effect.
    var curvature: CGFloat {
        let isVertical = axis == .vertical
        let thickness = isVertical ? width : height
        let length = isVertical ? height : width
        let inset = isVertical ? inset : 0
        let track = max(1, length - inset * 2)
        return min(1, thickness / track)
    }
    
    // Perceptual compensation for rounded capsule ends.
    // - Keeps bounds: f(0) = 0, f(1) = 1
    // - Monotonic and with unit slope at the ends to avoid "nerfed" motion near 0 or 1
    // - Symmetric bump centered at 0.5 increases apparent mid-range progress
    func compensate(_ p: CGFloat) -> CGFloat {
        let clamped = max(0, min(1, p))
        // Target a modest mid lift, capped for stability; scales with curvature.
        let midpointLift = min(0.06, 0.04 + 0.6 * curvature)
        let bump = clamped * (1 - clamped)          // 0 at edges, max at 0.5 (value 0.25)
        let power: CGFloat = 2                      // squared bump for stronger mid emphasis
        let bumpAtMid = pow(0.25, power)            // 0.0625 when power = 2
        let strength = midpointLift / bumpAtMid     // ensures f(0.5) = 0.5 + midpointLift
        let adjustment = strength * pow(bump, power)
        return max(0, min(1, clamped + adjustment))
    }
    
    // Mirrored compensation used for bad habits to guarantee symmetric offsets:
    // For all p in [0,1], 1 - compensate(p) == compensateMirrored(1 - p)
    // ⇒ base * (1 - compGood(1/3)) == base * compBad(2/3)
    func compensateMirrored(_ p: CGFloat) -> CGFloat {
        let clamped = max(0, min(1, p))
        return 1 - compensate(1 - clamped)
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
