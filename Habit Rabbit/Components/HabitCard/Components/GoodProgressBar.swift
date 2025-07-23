import SwiftUI

extension Habit.Card {
    struct GoodProgressBar: View {
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
                        // .background { targetBounceFiller }
                        .offset(
                            x: axis == .horizontal ? goodTargetOffset : 0,
                            y: axis == .vertical ? goodTargetOffset : 0
                        )
                        .shadow(color: .black.opacity(0.07), radius: 2, x: 0, y: -2)
                        .background { goodOverflowFiller }
                        .clipShape(.capsule)
                        .padding(axis == .vertical ? 3 : 0)
                }
                .geometryGroup()
                .frame(maxWidth: width, maxHeight: height)
                .animation(.bouncy, value: currentValue)
        }
    }
}

extension Habit.Card.GoodProgressBar {
    var progress: CGFloat {
        guard target > 0 else { return 0 }
        return CGFloat(currentValue) / CGFloat(target)
    }
    
    var goodTargetOffset: CGFloat {
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
    
    var goodOverflowOffset: CGFloat {
        if progress > 1 {
            return 0
        } else {
            return axis == .vertical ?
            goodTargetOffset + width / 2 :
            goodTargetOffset - height / 2
        }
    }
    
    var goodOverflowFiller: some View {
        Capsule()
            .fill(color.gradient)
            .brightness(colorScheme == .light ? -0.125 : -0.145)
            .rotationEffect(.degrees(180))
            .offset(
                x: axis == .horizontal ? goodOverflowOffset : 0,
                y: axis == .vertical ? goodOverflowOffset : 0
            )
    }
    
    var badOverflowOffset: CGFloat {
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
    
//    var targetBounceFiller: some View {
//        Rectangle()
//            .fill(color.gradient)
//            .frame(
//                width: axis == .vertical ? nil : width / 2 + height / 2,
//                height: axis == .vertical ? height / 2 + width / 2 : nil
//            )
//            .frame(
//                maxWidth: axis == .vertical ? .infinity : .infinity,
//                maxHeight: axis == .vertical ? .infinity : .infinity,
//                alignment: axis == .vertical ? .bottom : .leading
//            )
//            .offset(
//                x: axis == .vertical ? 0 : -height / 2,
//                y: axis == .vertical ? width / 2 : 0
//            )
//    }
}
