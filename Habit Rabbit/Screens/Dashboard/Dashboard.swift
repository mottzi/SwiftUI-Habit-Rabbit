import SwiftUI

extension Habit {
    
    struct Dashboard: View {
        
        @Namespace private var habitTransition
        @Environment(\.colorScheme) var colorScheme

        @Environment(Habit.Dashboard.Manager.self) var dashboardManager
        var cardManagers: [Habit.Card.Manager] { dashboardManager.cardManagers }

        @State var presentAddSheet = false
        @State var habitToEdit: Habit?

        var body: some View {
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
                                Habit.Card { habitToEdit = $0 }
                                    .environment(cardManager)
                                    .environment(\.cardOffset, index)
                                    .if(dashboardManager.useZoom) { view in
                                        view.matchedTransitionSource(id: cardManager.habit.id, in: habitTransition)
                                    }
                            }
                            .buttonStyle(.plain)
                            .background { Habit.Card.shadowEffect(colorScheme) }
                        }
                    }
                    .safeAreaInset(edge: .top, spacing: 0) { emptyView }
                    .safeAreaInset(edge: .top, spacing: 16) { gridHeader }
                    .padding([.horizontal, .bottom], 16)
                }
                .animation(.default, value: cardManagers.count)
                .sheet(isPresented: $presentAddSheet) { Sheet.Add() }
                .sheet(item: $habitToEdit) { Sheet.Edit(habit: $0) }
                .overlay(alignment: .bottomTrailing) { addHabitButton }
                .navigationTitle(String("Habit Rabbit"))
                .navigationBarTitleDisplayMode(dashboardManager.titleMode)
                #if DEBUG
                .toolbar { debugButton }
                #endif
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
