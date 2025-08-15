import SwiftUI
import SwiftData

extension Habit {

    struct Card: View {
        
        @Namespace var modeTransition

        @Environment(\.colorScheme) var colorScheme
        @Environment(\.cardMode) var cardMode
        @Environment(\.cardOffset) var cardOffset
        
        @Environment(Card.Manager.self) var cardManager
        @Environment(Dashboard.Manager.self) var dashboardManager
        
        var mode: Habit.Card.Mode { cardMode ?? cardManager.mode }
        
        @State var isDeleting = false
        
        var body: some View {
            let _ = print("Habit.Card: 🔄 \(cardManager.name)")
            // let _ = Self._printChanges()
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
            .background { Habit.Card.Background { colorEffect } }
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
    
    var habitLabel: some View {
        VStack(spacing: mode == .monthly ? 4 : 2) {
            Label("\(cardManager.name)", systemImage: cardManager.icon)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .lineLimit(1)
            
            if mode != .daily {
                (
                    Text("\(cardManager.currentValue(for: mode))")
                        .foregroundStyle(.primary.opacity(colorScheme == .dark ? 1 : 0.8))
                    +
                    Text(" / ")
                        .foregroundStyle(.primary.opacity(0.6))
                    +
                    Text("\(cardManager.currentTarget(for: mode))")
                        .foregroundStyle(.primary.opacity(0.6))
                )
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

extension Habit.Card {
    
    @ViewBuilder
    var contextMenuButtons: some View {
        Button("Randomize", systemImage: "sparkles") {
            cardManager.randomizeDailyValue()
        }
        Button("Randomize Name", systemImage: "characters.uppercase") {
            cardManager.randomizeName()
        }
        Button("Reset", systemImage: "arrow.counterclockwise") {
            cardManager.dailyValue?.currentValue = 0
        }
        Button("Delete", systemImage: "trash", role: .destructive) {
            deleteWithAnimation()
        }
    }
    
}
