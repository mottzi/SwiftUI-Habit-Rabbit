import SwiftUI
import SwiftData

extension Habit {
    
    struct Dashboard: View {
        
        @Namespace private var habitTransition
        @Environment(\.colorScheme) var colorScheme
        @Environment(Habit.Dashboard.Manager.self) var dashboardManager

        var cardManagers: [Card.Manager] { dashboardManager.cardManagers }
        
        var body: some View {
            let _ = print("Habit.Dashboard: 🔄 (\(cardManagers.count))")
            let _ = Self._printChanges()
            NavigationStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(cardManagers.enumerated, id: \.element.habit.id) { index, cardManager in
                            NavigationLink {
                                Habit.Card.DetailView()
                                    .environment(cardManager)
                                    .environment(dashboardManager)
                                    .if(dashboardManager.useZoomTransition) { view in
                                        view.navigationTransition(.zoom(sourceID: cardManager.habit.id, in: habitTransition))
                                    }
                            } label: {
                                Habit.Card()
                                    .environment(cardManager)
                                    .environment(\.cardOffset, index)
                                    .if(dashboardManager.useZoomTransition) { view in
                                        view.matchedTransitionSource(id: cardManager.habit.id, in: habitTransition)
                                    }
                            }
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
            .tint(colorScheme == .dark ? .white : .black)
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
