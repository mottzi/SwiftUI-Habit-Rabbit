import SwiftUI

extension Habit.Card {
    
    struct Background<Background: View>: View {
        
        @Environment(\.colorScheme) var colorScheme
        
        private let extraBackground: Background
        
        init(@ViewBuilder background: () -> Background) {
            self.extraBackground = background()
        }
        
        var body: some View {
            RoundedRectangle(cornerRadius: 24)
                .fill(.regularMaterial)
                .stroke(.quaternary, lineWidth: colorScheme == .dark ? 1 : 0.6)
                .background {
                    shadow
                    extraBackground
                }
        }
        
        private var shadow: some View {
            ZStack {
                if colorScheme == .light {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.black.opacity(0.09))
                        .blur(radius: 10)
                        .offset(x: 0, y: 4)
                    
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.black.opacity(0.05))
                        .blur(radius: 4)
                        .offset(x: 0, y: 2)
                    
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(uiColor: .systemBackground))
                }
            }
        }
        
    }
    
}

extension Habit.Card.Background where Background == EmptyView {
    
    init() { self.init { EmptyView() } }
    
}
