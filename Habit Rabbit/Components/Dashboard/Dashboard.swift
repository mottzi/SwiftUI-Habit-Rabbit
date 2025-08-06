import SwiftUI
import SwiftData

extension Habit {
    
    struct Dashboard: View {
        
        @Environment(\.colorScheme) var colorScheme
        let modelContext: ModelContext
        
        @State var dashboardManager: Habit.Dashboard.Manager? = nil
        var manager: Habit.Dashboard.Manager { dashboardManager! }
        var cardManagers: [Habit.Card.Manager] { manager.cardManagers }
        
        var body: some View {
            let _ = Self._printChanges()
            VStack {
                if let dashboardManager {
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
            }
            .task {
                if dashboardManager == nil {
                    dashboardManager = Habit.Dashboard.Manager(using: modelContext)
                }
            }
        }
        
        private let columns = [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16),
        ]
        
//        init(using modelContext: ModelContext) {
//            print("Dashboard initializing ... ")
//            let manager = Habit.Dashboard.Manager(using: modelContext)
//            self._dashboardManager = State(initialValue: manager)
//        }
        
    }
    
}

extension Habit.Dashboard {
    
    private var modePicker: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            ModePicker(
                width: 240,
                mode: manager.mode,
                onSelection: { newMode in
                    manager.updateMode(newMode)
                }
            )
            .padding(.leading, 8)
            .sensoryFeedback(.selection, trigger: manager.mode)
        }
    }
    
}
