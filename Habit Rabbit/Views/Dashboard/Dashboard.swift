import SwiftUI

extension Habit {
    
    struct Dashboard: View {
        
        @Environment(\.colorScheme) var colorScheme
        @Environment(Habit.Dashboard.Manager.self) var dashboardManager

        @State var showAddSheet = false
        @State var editingHabit: Habit?
        
        @Namespace var unionNamespace
        
        var cardManagers: [Habit.Card.Manager] { dashboardManager.cardManagers }

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
                    .safeAreaPadding(.top, 4)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                .scrollEdgeEffectHidden(for: .bottom)
                .safeAreaPadding(.top, 6)
                .safeAreaBar(edge: .top) { controls }
                .toolbar { toolbar }
                .toolbarRole(.browser)
                .toolbarTitleDisplayMode(.inline)
                .animation(.default, value: cardManagers.count)
                .sheet(isPresented: $showAddSheet) { Sheet.Add() }
                .sheet(item: $editingHabit) { Sheet.Edit(habit: $0) }
            }
            .tint(colorScheme == .dark ? .white : .black)
            .sensoryFeedback(.selection, trigger: dashboardManager.mode)
            .sensoryFeedback(.selection, trigger: dashboardManager.lastDay)
            .onCalendarDayChanged { dashboardManager.setLastDay(to: .now) }
        }
        
        private let columns = [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16),
        ]
        
    }
    
}
