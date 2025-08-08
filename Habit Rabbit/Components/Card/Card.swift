import SwiftUI
import SwiftData

extension Habit {

    struct Card: View {
        
        @Environment(Card.Manager.self) var cardManager
        @Environment(Dashboard.Manager.self) var dashboardManager
        
        @Environment(\.cardMode) var cardMode
        @Environment(\.cardOffset) var cardOffset
        @Environment(\.colorScheme) var colorScheme
        
        @Namespace var modeTransition
        @State var isDeleting = false
        
        var mode: Habit.Card.Mode {
            cardMode ?? cardManager.mode
        }
        
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
                
                habitLabel(for: mode)
            }
            .animation(.spring(duration: 0.62), value: mode)
            .frame(maxWidth: .infinity)
            .frame(height: 232)
            .background { Habit.CardSurface { colorEffect } }
            .geometryGroup()
            .scaleEffect(isDeleting ? 0 : 1)
            .contentShape(.contextMenuPreview, .rect(cornerRadius: 24))
            .contextMenu { contextMenuButtons }
            .offset(isDeleting ? deleteOffset : .zero)
            .compositingGroup()
        }
        
    }
    
}

extension Habit.Card {
    
    @ViewBuilder
    func habitLabel(for mode: Habit.Card.Mode) -> some View {
        VStack(spacing: mode == .monthly ? 4 : 2) {
            Label("\(cardManager.name)", systemImage: cardManager.icon)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .lineLimit(1)
            
            if mode != .daily {
                progressLabelCompact
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
            .clipShape(.rect(cornerRadius: 24))
            .animation(.bouncy, value: cardManager.isCompleted(for: mode))
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
    
    enum Mode: String, CaseIterable {
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
    }
    
}

extension EnvironmentValues {
    
    @Entry var cardOffset: Int = 0
    @Entry var cardMode: Habit.Card.Mode? = nil
    
}

extension Habit.Card {
    
    func cardMode(_ mode: Habit.Card.Mode) -> some View {
        self.environment(\.cardMode, mode)
    }
    
}
