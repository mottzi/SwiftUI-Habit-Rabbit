import SwiftUI

extension Habit.Card {
    struct BadProgressBar: View {
        @Environment(\.colorScheme) var colorScheme
        
        let currentValue: Int
        let target: Int
        let color: Color
        let axis: Axis
        let width: CGFloat
        let height: CGFloat
        
        // Explicit colors for each layer as requested.
        private let allowanceColor: Color
        private let depletedColor: Color
        private let overflowColor: Color
        
        init(currentValue: Int, target: Int, color: Color, axis: Axis, width: CGFloat, height: CGFloat) {
            self.currentValue = currentValue
            self.target = target
            self.color = color
            self.axis = axis
            self.width = width
            self.height = height
            
            self.allowanceColor = color
            self.depletedColor = Color(red: 63/255, green: 63/255, blue: 65/255)
            self.overflowColor = Color(red: 63/255, green: 63/255, blue: 65/255)
        }
        
        var body: some View {
            Capsule()
                .fill(Color(red: 63/255, green: 63/255, blue: 65/255))
                .overlay {
                    ZStack {
                        // bottom overflow dark
                        Capsule()
                            .fill(overflowColor)
                        
                        // top depletion color light
                        Capsule()
                            .fill(depletedColor.gradient)
                            .rotationEffect(.degrees(180))
                            .offset(y: depletedOffset)
                            .shadow(color: .black.opacity(0.7), radius: 2, x: 0, y: -2)

                        // habit color
                        Capsule()
                            .fill(allowanceColor.gradient)
                            .offset(y: allowanceOffset)
                    }
                    .clipShape(Capsule())
                    .padding(axis == .vertical ? 3 : 0)
                }
//                .clipShape(.capsule)
                .geometryGroup()
                .frame(maxWidth: width, maxHeight: height)
                .animation(.bouncy, value: currentValue)
        }
    }
}

extension Habit.Card.BadProgressBar {
    var progress: CGFloat {
        guard target > 0 else { return 0 }
        return CGFloat(currentValue) / CGFloat(target)
    }
    
    var allowanceOffset: CGFloat {
        let dimension = axis == .vertical ? height : width
        let padding = axis == .vertical ? 12.0 : -0.0
        
        switch axis {
            case .vertical:
                switch progress {
                    case 0:
                        // When progress is 0, the offset must be 0.
                        return 0
                    case 0..<1:
                        // Apply the padding adjustment ONLY when progress is between 0 and 1.
                        return (dimension * progress) - padding
                    default: // Covers progress >= 1
                             // The bar is fully depleted.
                        return dimension
                }
                
            case .horizontal:
                // The horizontal axis does not use padding, so its logic remains simple.
                return progress < 1 ? (dimension * progress) : -dimension
        }
    }
    
    /// Controls the MIDDLE (Black) capsule's offset.
    var depletedOffset: CGFloat {
        let dimension = axis == .vertical ? height : width
        let padding = axis == .vertical ? 12.0 : -0.0
        
        if progress > 1 {
            // --- Overflow State ---
            // The black capsule moves UP (negative offset) to reveal the pink layer.
            // This mirrors the GoodProgressBar's overflow mechanic.
            let overflowAmount = dimension * (1 - (1 / progress)) - padding
            return -overflowAmount
        } else {
            // --- Depletion State ---
            // The black capsule is stationary, acting as the background for the red mover.
            return 0
        }
    }
}
