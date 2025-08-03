import SwiftUI
import SwiftData

extension Habit.Card {

    enum Mode: String, CaseIterable {
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
    }
    
}

extension Habit {

    struct Card: View {
        
        @Environment(\.modelContext) var modelContext
        @Environment(\.colorScheme) var colorScheme
        @Namespace var modeTransition
        
        let manager: Habit.Card.Manager
        let index: Int
        let onDelete: () -> Void
        
        @State var isDeleting = false
        
        var body: some View {
            let _ = print("🔄 Card body evaluated: \(manager.habit.name)")
            VStack(spacing: 0) {
                Group {
                    switch manager.mode {
                        case .daily: dailyView
                        case .weekly: weeklyView
                        case .monthly: monthlyView
                    }
                }
                .transition(.blurReplace)
                
                VStack(spacing: manager.mode == .monthly ? 4 : 2) {
                    habitLabel
                    if manager.mode != .daily {
                        progressLabelCompact
                    }
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, manager.labelBottomPadding)
            }
            .animation(.spring(duration: 0.62), value: manager.mode)
            .frame(maxWidth: .infinity)
            .frame(height: 232)
            .background { background }
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
    var contextMenuButtons: some View {
        Button("Randomize", systemImage: "sparkles") {
            manager.randomizeLastDayValue()
        }
        Button("Reset", systemImage: "arrow.counterclockwise") {
            manager.lastDayValue?.currentValue = 0
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
            } completion: {
                isDeleting = false
            }
            
            try? await Task.sleep(nanoseconds: 10_000_000)
            modelContext.delete(manager.habit)
            
            onDelete()
        }
    }
    
    var deleteOffset: CGSize {
        let offset = (index % 2 == 0) ? -250 : 250
        return CGSize(width: CGFloat(offset), height: 100)
    }
    
}
