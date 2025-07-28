import SwiftUI
import SwiftData

extension Habit.Card {
    // length of time interval habit card can display values for
    enum Mode: String, CaseIterable {
        case daily = "Daily" // current day
        case weekly = "Weekly" // last 7 days
        case monthly = "Monthly" // last 30 days
    }
}


extension Habit {
    // displays the value data of a habit for the time interval specified
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
                .padding(.bottom, labelBottomPadding)
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
        
        let contentHeight: CGFloat = 155
        
        var labelBottomPadding: CGFloat {
            switch manager.mode {
                case .daily: 20
                case .weekly: 10
                case .monthly: 14
            }
        }
    }
}

extension Habit.Card {
    @ViewBuilder
    var contextMenuButtons: some View {
        Button("Weekly Values", systemImage: "7.circle.fill") {
            for value in manager.weeklyValues {
                print("Value: \(value.currentValue)")
            }
        }
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
        // animate card before deleting habit and all its values from context
        Task {
            try? await Task.sleep(nanoseconds: 10_000_000)
            withAnimation(.spring(duration: 0.8)) {
                isDeleting = true
            } completion: {
                isDeleting = false
            }
            
            try? await Task.sleep(nanoseconds: 10_000_000)
            modelContext.delete(manager.habit)
            
            // here we need the parent to fetch and reconcile
            onDelete()
        }
    }
    
    var deleteOffset: CGSize {
        // cards animate towards nearest horizontal edge
        let offset = (index % 2 == 0) ? -250 : 250
        return CGSize(width: CGFloat(offset), height: 100)
    }
}
