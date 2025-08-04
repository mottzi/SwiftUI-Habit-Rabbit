import SwiftUI
import SwiftData

extension Habit {
    
    struct Dashboard: View {
        
        @Environment(\.colorScheme) var colorScheme
        @State var dashboardManager: Habit.Dashboard.Manager
        var cardManagers: [Habit.Card.Manager] { dashboardManager.cardManagers }
        
        var body: some View {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(cardManagers.enumerated, id: \.element.habit.id) { index, cardManager in
                        Habit.Card(
                            manager: cardManager,
                            index: index,
                            onDelete: dashboardManager.refreshCardManagers
                        )
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
        
        init(using modelContext: ModelContext) {
            let manager = Habit.Dashboard.Manager(using: modelContext)
            self._dashboardManager = State(initialValue: manager)
        }
        
    }
    
}

extension Habit.Dashboard {
    
    private var modePicker: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            ModePicker(
                width: 240,
                mode: $dashboardManager.mode
            )
            .padding(.leading, 8)
            .sensoryFeedback(.selection, trigger: dashboardManager.mode)
        }
    }
    
}
