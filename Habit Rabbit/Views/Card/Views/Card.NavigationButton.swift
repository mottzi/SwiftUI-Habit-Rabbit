import SwiftUI

extension Habit.Card {
    
    struct NavigationButton: View {
        
        @Binding var editingHabit: Habit?

        @Environment(\.colorScheme) var colorScheme
        @Environment(\.cardOffset) var cardIndex
        @Environment(Habit.Card.Manager.self) var cardManager
        @Environment(Habit.Dashboard.Manager.self) var dashboardManager
        
        @Namespace var habitTransition
        
        var body: some View {
            NavigationLink {
                Habit.Card.DetailView()
                    .environment(cardManager)
                    .environment(dashboardManager)
                    .navigationTransition(.zoom(sourceID: cardManager.habit.id, in: habitTransition))
            } label: {
                Habit.Card(editingHabit: $editingHabit)
                    .environment(cardManager)
                    .environment(\.cardOffset, cardIndex)
                    .matchedTransitionSource(id: cardManager.habit.id, in: habitTransition)
            }
            .fontDesign(.rounded)
            .buttonStyle(.plain)
            .background { Habit.Card.shadowEffect(colorScheme) }
        }
        
    }
    
}
