import SwiftUI

extension Habit.Card {
    struct ProgressBar: View {
        @Environment(\.colorScheme) var colorScheme
        
        let currentValue: Int
        let target: Int
        let color: Color
        let axis: Axis
        let width: CGFloat
        let height: CGFloat
        
        var body: some View {
            Capsule()
                .fill(.quaternary)
                .overlay {
                    Capsule()
                        .fill(color.gradient)
                        .background { targetBounceFiller }
                        .offset(
                            x: axis == .horizontal ? targetOffset : 0,
                            y: axis == .vertical ? targetOffset : 0
                        )
                        .shadow(color: .black.opacity(0.07), radius: 2, x: 0, y: -2)
                        .background { overflowFiller }
                        .clipShape(.capsule)
                        .padding(axis == .vertical ? 3 : 0)
                }
                .frame(maxWidth: width, maxHeight: height)
        }
    }
}

extension Habit.Card.ProgressBar {
    var progress: CGFloat {
        guard target > 0 else { return 0 }
        return CGFloat(currentValue) / CGFloat(target)
    }
    
    var targetOffset: CGFloat {
        let dimension = axis == .vertical ? height : width
        let padding = axis == .vertical ? 12.0 : -0.0
        
        switch axis {
            case .vertical: do {
                return switch progress {
                    case  ...0: dimension
                    case 0..<1: dimension * (1 - progress) - padding
                    case     1: 0
                    case  1...: dimension * (1 - (1 / progress)) - padding
                    default   : dimension
                }
            }
            case .horizontal: do {
                return switch progress {
                    case  ...0: -dimension
                    case 0..<1: -dimension * (1 - progress) + padding
                    case     1: 0
                    case  1...: -dimension * (1 - (1 / progress)) + padding
                    default   : -dimension
                }
            }
        }
    }
    
    var overflowOffset: CGFloat {
        if progress > 1 {
            return 0
        } else {
            return axis == .vertical ?
            targetOffset + width / 2 :
            targetOffset - height / 2
        }
    }
    
    var targetBounceFiller: some View {
        Rectangle()
            .fill(color.gradient)
            .frame(
                width: axis == .vertical ? nil : width / 2 + height / 2,
                height: axis == .vertical ? height / 2 + width / 2 : nil
            )
            .frame(
                maxWidth: axis == .vertical ? .infinity : .infinity,
                maxHeight: axis == .vertical ? .infinity : .infinity,
                alignment: axis == .vertical ? .bottom : .leading
            )
            .offset(
                x: axis == .vertical ? 0 : -height / 2,
                y: axis == .vertical ? width / 2 : 0
            )
    }
    
    var overflowFiller: some View {
        Capsule()
            .fill(color.gradient)
            .brightness(colorScheme == .light ? -0.125 : -0.200)
            .rotationEffect(.degrees(180))
            .offset(
                x: axis == .horizontal ? overflowOffset : 0,
                y: axis == .vertical ? overflowOffset : 0
            )
    }
}
