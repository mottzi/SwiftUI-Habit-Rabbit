import SwiftUI

extension EnvironmentValues {
    
    @Entry var showShadows: Bool? = nil
    
}

extension View {
    
    func showShadows(_ show: Bool) -> some View {
        self.environment(\.showShadows, show)
    }
    
}

extension Habit.Card {
    
    struct Background<B: View, S: InsettableShape>: View {
        
        @Environment(\.colorScheme) var colorScheme
        @Environment(\.showShadows) var showShadows
        
        private let extraBackground: B
        private let shape: S
        
        init(
            shape: S,
            @ViewBuilder background: () -> B
        ) {
            self.shape = shape
            self.extraBackground = background()
        }
        
        var body: some View {
            shape
                .fill(.regularMaterial)
                .stroke(.quaternary, lineWidth: colorScheme == .dark ? 1 : 0.6)
                .background {
                    if showShadows ?? true {
                        shadowView
                    }
                    extraBackground
                }
        }
        
        private var shadowView: some View {
            ZStack {
                if colorScheme == .light {
                    shape
                        .fill(.black.opacity(0.09))
                        .blur(radius: 10)
                        .offset(x: 0, y: 4)
                    
                    shape
                        .fill(.black.opacity(0.05))
                        .blur(radius: 4)
                        .offset(x: 0, y: 2)
                    
                    shape
                        .fill(Color(uiColor: .systemBackground))                    
                }
            }
        }
        
    }
    
}

extension Habit.Card.Background where S == RoundedRectangle {
    
    init(shadow: Bool = true, @ViewBuilder background: () -> B) {
        self.init(
            shape: RoundedRectangle(cornerRadius: Habit.Card.Manager.cornerRadius),
            background: background
        )
    }
    
}

extension Habit.Card.Background where B == EmptyView, S == RoundedRectangle {
    
    init(shadow: Bool = true) {
        self.init(shape: RoundedRectangle(cornerRadius: Habit.Card.Manager.cornerRadius)) {
            EmptyView()
        }
    }
    
}

extension Habit.Card.Background where B == EmptyView {
    
    init(in shape: S) {
        self.init(shape: shape) { EmptyView() }
    }
    
}
