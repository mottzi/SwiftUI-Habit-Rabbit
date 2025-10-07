import SwiftUI

extension Habit {
    
    struct Dashboard: View {
        
        @Environment(\.colorScheme) var colorScheme
        @Environment(Habit.Dashboard.Manager.self) var dashboardManager

        @State var showAddSheet = false
        @State var editingHabit: Habit?
        
        var cardManagers: [Habit.Card.Manager] { dashboardManager.cardManagers }

        var body: some View {
            NavigationStack {
                VStack {
                    Circle()
                        .fill(.red.gradient)
                        .frame(width: 100)
                    
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(cardManagers.enumerated, id: \.element.habit.id) { index, cardManager in
                                Habit.Card.NavigationButton(editingHabit: $editingHabit)
                                    .environment(cardManager)
                                    .environment(dashboardManager)
                                    .environment(\.cardOffset, index)
                            }
                        }
                        .safeAreaInset(edge: .top, spacing: 0) { emptyGridView }
                        .safeAreaInset(edge: .top, spacing: 0) { gridHeader }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                    .safeAreaPadding(.top, 70)
                    .overlay(alignment: .top) {
                        @Bindable var manager = dashboardManager
                        if #available(iOS 26.0, *) {
                            Picker("View Mode", selection: $manager.mode) {
                                ForEach(Habit.Card.Mode.allCases) { item in
                                    Text(item.localizedTitle)
                                }
                            }
                            .pickerStyle(.segmented)
                            .glassEffect()
                            .controlSize(.large)
                            .sensoryFeedback(.selection, trigger: manager.mode)
                            .padding(.horizontal, 50)
                            .padding(.top, 8)
                        }
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 40)
                            .fill(Color(white: colorScheme == .dark ? 0.08 : 0.9))
                            .padding(.bottom, -500)
                    }
                    .clipShape(
                        UnevenRoundedRectangle(topLeadingRadius: 40, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 40)
                    )
                    .overlay(alignment: .bottomTrailing) { addHabitButton }
                    .ignoresSafeArea(.container, edges: .bottom)
                    .animation(.default, value: cardManagers.count)
                    .sheet(isPresented: $showAddSheet) { Sheet.Add() }
                    .sheet(item: $editingHabit) { Sheet.Edit(habit: $0) }
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        #if DEBUG
                        debugToolbarMenu
                        #endif
                        lastDayToolbarLabel
                        previousDayToolbarButton
                        nextDayToolbarButton
                        addHabitToolbarButton
                    }
                }
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
