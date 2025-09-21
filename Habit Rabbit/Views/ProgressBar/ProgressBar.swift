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
                .strokeBorder(.quaternary, lineWidth: trackBorderWidth)
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
