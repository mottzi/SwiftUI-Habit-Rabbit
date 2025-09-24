import SwiftUI

extension Habit {
    
    struct Dashboard: View {
        
        @Environment(\.colorScheme) var colorScheme
        @Environment(Habit.Dashboard.Manager.self) var dashboardManager
        var cardManagers: [Habit.Card.Manager] { dashboardManager.cardManagers }

        @State var showAddSheet = false
        @State var editingHabit: Habit?
        
        var body: some View {
            NavigationStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(cardManagers.enumerated, id: \.element.habit.id) { index, cardManager in
                            Habit.Card.NavigationButton(editingHabit: $editingHabit)
                                .environment(cardManager)
                                .environment(dashboardManager)
                                .environment(\.cardOffset, index)
                        }
                    }
                    .safeAreaInset(edge: .top, spacing: 0) { emptyView }
                    .safeAreaInset(edge: .top, spacing: 16) { gridHeader }
                    .padding([.horizontal, .bottom], 16)
                }
                .overlay(alignment: .bottomTrailing) { addHabitButton }
                .ignoresSafeArea(.container, edges: .bottom)
                .animation(.default, value: cardManagers.count)
                .sheet(isPresented: $showAddSheet) { Sheet.Add() }
                .sheet(item: $editingHabit) { Sheet.Edit(habit: $0) }
                .navigationTitle(String("Habit Rabbit"))
                .navigationBarTitleDisplayMode(.inline)
                #if DEBUG
                .toolbar { debugButton }
                #endif
            }
            .tint(colorScheme == .dark ? .white : .black)
            .fontDesign(.rounded)
            .onCalendarDayChanged { dashboardManager.setLastDay(to: .now) }
        }
        
        private let columns = [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16),
        ]
        
    }
    
}
