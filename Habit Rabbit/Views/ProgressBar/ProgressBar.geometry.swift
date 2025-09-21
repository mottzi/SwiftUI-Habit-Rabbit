import SwiftUI

extension Habit.ProgressBar {
    
    var progress: CGFloat {
        guard target > 0 else { return 0 }
        return CGFloat(value) / CGFloat(target)
    }
    
    var offset: CGFloat {
        let dimension = axis == .vertical ? height : width
        
        let base = switch (kind, axis) {
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
    private func compensate(_ progress: CGFloat) -> CGFloat {
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
    private var curvature: CGFloat {
        let isVertical = axis == .vertical
        let thickness = isVertical ? width : height
        let length = isVertical ? height : width
        let inset = isVertical ? inset : 0
        let track = max(1, length - inset * 2)
        return min(1, thickness / track)
    }
    
}
