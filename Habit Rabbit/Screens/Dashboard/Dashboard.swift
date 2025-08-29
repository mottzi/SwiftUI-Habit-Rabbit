import SwiftUI
import SwiftData

extension Habit {
    
    struct Dashboard: View {
        
        @Namespace private var habitTransition
        @Environment(\.colorScheme) var colorScheme
        @Environment(\.scenePhase) private var scenePhase

        @Environment(Habit.Dashboard.Manager.self) var dashboardManager
        var cardManagers: [Card.Manager] { dashboardManager.cardManagers }

        @State private var presentAddSheet = false

        var body: some View {
            let _ = print("Habit.Dashboard: 🔄 \(cardManagers.count) Habit.Cards")
            // let _ = Self._printChanges()
            NavigationStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(cardManagers.enumerated, id: \.element.habit.id) { index, cardManager in
                            NavigationLink {
                                Habit.Card.DetailView()
                                    .environment(cardManager)
                                    .environment(dashboardManager)
                                    .if(dashboardManager.useZoom) { view in
                                        view.navigationTransition(.zoom(sourceID: cardManager.habit.id, in: habitTransition))
                                    }
                            } label: {
                                Habit.Card()
                                    .environment(cardManager)
                                    .environment(\.cardOffset, index)
                                    .if(dashboardManager.useZoom) { view in
                                        view.matchedTransitionSource(id: cardManager.habit.id, in: habitTransition)
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                    .padding(.top, -4)
                }
                .safeAreaInset(edge: .top) { gridHeader }
                .animation(.default, value: cardManagers.count)
                .sheet(isPresented: $presentAddSheet) { AddHabitSheet() }
                .overlay(alignment: .bottomTrailing) { debugButton }
                .navigationTitle("Habit Rabbit")
                .navigationBarTitleDisplayMode(dashboardManager.useInline ? .inline : .automatic)
                .toolbar { addHabitButton }
            }
            .tint(colorScheme == .dark ? .white : .black)
            .onCalendarDayChanged { dashboardManager.setLastDay(to: .now) }
        }
        
        private let columns = [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16),
        ]
        
    }
    
}

extension Habit.Dashboard {
    
    private var addHabitButton: some ToolbarContent {
        ToolbarItem {
            Button("Add Habit", systemImage: "plus") {
                presentAddSheet = true
            }
            .buttonBorderShape(.circle)
            .buttonStyle(.borderedProminent)
            .fontWeight(.semibold)
            .tint(.blue)
        }
    }
    
}
