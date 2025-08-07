import SwiftUI
import SwiftData

extension Habit {
    
    struct Dashboard: View {
        
        @Environment(\.colorScheme) var colorScheme
        @Environment(Habit.Dashboard.Manager.self) var dashboardManager
        @Namespace private var habitTransition

        var cardManagers: [Card.Manager] { dashboardManager.cardManagers }
        
        var body: some View {
            let _ = print("Habit.Dashboard: 🔄 (\(cardManagers.count))")
            let _ = Self._printChanges()
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(cardManagers.enumerated, id: \.element.habit.id) { index, cardManager in
                        NavigationLink {
                            HabitDetailView()
                                .environment(cardManager)
                                .environment(dashboardManager)
                                .navigationTransition(.zoom(sourceID: cardManager.habit.id, in: habitTransition))
                        } label: {
                            Habit.Card()
                                .environment(cardManager)
                                .environment(\.cardOffset, index)
                        }
                        .matchedTransitionSource(id: cardManager.habit.id, in: habitTransition)
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
                .safeAreaInset(edge: .bottom) {
                    debugButton
                        .padding(.vertical, 16)
                }
            }
            .navigationTitle("Habit Rabbit")
            .animation(.default, value: cardManagers.count)
            .toolbar { modePicker }
        }
        
        private let columns = [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16),
        ]
        
    }
    
}

extension Habit.Dashboard {
    
    private var modePicker: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            ModePicker(
                width: 240,
                mode: dashboardManager.mode,
                onSelection: { newMode in
                    dashboardManager.updateMode(newMode)
                }
            )
            .padding(.leading, 8)
            .sensoryFeedback(.selection, trigger: dashboardManager.mode)
        }
    }
    
}
