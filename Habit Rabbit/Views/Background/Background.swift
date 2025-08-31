import SwiftUI

extension EnvironmentValues {
    
    @Entry var showShadows: Bool? = nil
    
}

extension Habit.Card.Background {
    
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
        private let material: Material
        
        init(
            shape: S,
            material: Material = .regularMaterial,
            @ViewBuilder background: () -> B
        ) {
            self.shape = shape
            self.material = material
            self.extraBackground = background()
        }
        
        var body: some View {
            shape
                .fill(material)
                .strokeBorder(.quaternary, lineWidth: colorScheme == .dark ? 1 : 0.6)
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
                }
            }
        }
        
    }
    
}

extension Habit.Card.Background where S == RoundedRectangle {
    
    init(@ViewBuilder background: () -> B) {
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
    
    init(in shape: S, material: Material = .regularMaterial) {
        self.init(shape: shape, material: material) { EmptyView() }
    }
    
}
