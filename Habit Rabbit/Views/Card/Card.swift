import SwiftUI
import SwiftData

extension Habit {

    struct Card: View {
        
        @Binding var editingHabit: Habit?

        @Environment(\.colorScheme) var colorScheme
        @Environment(\.cardMode) var cardMode
        @Environment(\.cardOffset) var cardOffset
        @Environment(Card.Manager.self) var cardManager
        @Environment(Dashboard.Manager.self) var dashboardManager
        
        @Namespace var modeTransition

        var mode: Habit.Card.Mode { cardMode ?? cardManager.mode }
        
        @State var isDeleting = false
        
        var body: some View {
            VStack(spacing: 0) {
                Group {
                    switch mode {
                        case .daily: dailyView
                        case .weekly: weeklyView
                        case .monthly: monthlyView
                    }
                }
                .transition(.blurReplace)
                
                habitLabel
            }
            .animation(.spring(duration: 0.62), value: mode)
            .animation(.spring(duration: 0.62), value: cardManager.lastDay)
            .frame(maxWidth: .infinity)
            .frame(height: Card.Manager.cardHeight)
            .clipShape(.rect(cornerRadius: Card.Manager.cornerRadius))
            .background { Habit.Card.Background { colorEffect }.showShadows(false) }
            .geometryGroup()
            .scaleEffect(isDeleting ? 0 : 1)
            .contentShape(.contextMenuPreview, .rect(cornerRadius: Manager.cornerRadius))
            .contextMenu { contextMenuButtons }
            .offset(isDeleting ? deleteOffset : .zero)
            .compositingGroup()
        }
        
    }
    
}

extension Habit.Card {
    
    @ViewBuilder
    static func shadowEffect(_ colorScheme: ColorScheme) -> some View {
        if colorScheme == .light {
            RoundedRectangle(cornerRadius: Habit.Card.Manager.cornerRadius)
                .fill(.black.opacity(0.08))
                .blur(radius: 10)
                .offset(x: 0, y: 4)
            
            RoundedRectangle(cornerRadius: Habit.Card.Manager.cornerRadius)
                .fill(.black.opacity(0.04))
                .blur(radius: 4)
                .offset(x: 0, y: 2)
        }
    }
    
}

extension Habit.Card {
    
    var habitLabel: some View {
        VStack(spacing: mode == .monthly ? 4 : 2) {
            Label(String("\(cardManager.name)"), systemImage: cardManager.icon)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .lineLimit(1)
            
            if mode != .daily {
                let valueText = Text(verbatim: "\(cardManager.currentValue(for: mode))")
                    .foregroundStyle(.primary.opacity(colorScheme == .dark ? 1 : 0.8))
                let slashText = Text(verbatim: " / ")
                    .foregroundStyle(.primary.opacity(0.6))
                let targetText = Text(verbatim: "\(cardManager.currentTarget(for: mode))")
                    .foregroundStyle(.primary.opacity(0.6))
                
                Text("\(valueText)\(slashText)\(targetText)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .monospacedDigit()
                    .contentTransition(.numericText())
            }
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, cardManager.labelBottomPadding)
    }
    
    var colorEffect: some View {
        Rectangle()
            .fill(cardManager.color.gradient)
            .opacity(cardManager.isCompleted(for: mode) ? (colorScheme == .dark ? 0.5 : 0.7) : 0)
            .offset(x: 0, y: 180)
            .clipShape(.rect(cornerRadius: Manager.cornerRadius))
            .animation(.bouncy, value: cardManager.isCompleted(for: mode))
    }
    
}

extension EnvironmentValues {
    
    @Entry var cardOffset: Int = 0
    
}

extension Habit.Card {
    
    func deleteWithAnimation() {
        Task {
            try? await Task.sleep(nanoseconds: 10_000_000)
            withAnimation(.spring(duration: 0.8)) {
                isDeleting = true
            }
            
            try? await Task.sleep(nanoseconds: 10_000_000)
            cardManager.modelContext.delete(cardManager.habit)
            
            dashboardManager.refreshCardManagers()
        }
    }
    
    var deleteOffset: CGSize {
        let offset = (cardOffset % 2 == 0) ? -250 : 250
        return CGSize(width: CGFloat(offset), height: 100)
    }
    
}
