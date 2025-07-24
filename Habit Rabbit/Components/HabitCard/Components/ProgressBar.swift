import SwiftUI

extension Habit.Card {
    struct ProgressBar: View {
        @Environment(\.colorScheme) var colorScheme
        
        let currentValue: Int
        let target: Int
        let color: Color
        let axis: Axis
        let kind: Habit.Kind
        let width: CGFloat
        let height: CGFloat
        
        var body: some View {
            Capsule()
                .fill(.quaternary)
                .overlay {
                    Capsule()
                        .fill(color.gradient)
                        .offset(
                            x: axis == .horizontal ? offset : 0,
                            y: axis == .vertical ? offset : 0
                        )
                        .shadow(color: .black.opacity(0.07), radius: 2, x: 0, y: -2)
                        .clipShape(.capsule)
                        .padding(axis == .vertical ? 3 : 0)
                }
                .geometryGroup()
                .frame(maxWidth: width, maxHeight: height)
                .animation(.bouncy, value: currentValue)
        }
    }
}

extension Habit.Card.ProgressBar {
    var progress: CGFloat {
        guard target > 0 else { return 0 }
        return CGFloat(currentValue) / CGFloat(target)
    }
    
    var offset: CGFloat {
        // get track length
        let max = axis == .vertical ? height : width
        
        // visual offset for better appearance
        let padding = axis == .vertical ? -12.0 : 0.0
        
        // good: track fills bottom to top or left toright)
        // bad: track depletes top to bottom or right to left
        let baseOffset: CGFloat = switch (kind, axis) {
            case (.good, .vertical): max      // fills upward
            case (.good, .horizontal): -max   // fills rightward
            case (.bad, .vertical): max       // depletes downward
            case (.bad, .horizontal): -max    // depletes leftward
        }
        
        return switch progress {
            // no progress -> good: start hidden, bad: start full
            case ...0: kind == .good ? baseOffset : 0
            // partial progress -> good: fill up, bad: deplete down
            case 0..<1: baseOffset * (kind == .good ? 1 - progress : progress) + padding
            // target reached -> good: fully visible, Bad: fully hidden
            case 1...: kind == .good ? 0 : baseOffset
            // edge cases
            default: kind == .good ? baseOffset : 0
        }
    }
}
