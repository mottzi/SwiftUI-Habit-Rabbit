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
                    .safeAreaInset(edge: .bottom) { debugButton }
                    // .safeAreaInset(edge: .top) { shiftLastDayControls }
                }
                .navigationTitle("Habit Rabbit")
                .animation(.default, value: cardManagers.count)
                .overlay(alignment: .bottomTrailing) { addHabitButton }
                .toolbar { modePicker }
                .sheet(isPresented: $presentAddSheet) { AddHabitSheet() }
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
    
    private var modePicker: some ToolbarContent {
        ToolbarItem(/*placement: .topBarTrailing*/) {
            ModePicker(
                width: 240,
                mode: dashboardManager.mode,
                onSelection: { mode in
                    dashboardManager.updateMode(to: mode)
                }
            )
            .padding(.leading, 8)
            .sensoryFeedback(.selection, trigger: dashboardManager.mode)
        }
    }
    
    private var addHabitButton: some View {
        Button {
            presentAddSheet = true
        } label: {
            Image(systemName: "plus")
                .font(.title)
                .fontWeight(.medium)
                .foregroundStyle(colorScheme == .light ? .black : .white)
                .frame(width: 70, height: 70)
                .background { Habit.Card.Background(in: .circle, material: .ultraThinMaterial) }
                .padding()
                .padding(.trailing, -6)
        }
        .buttonStyle(.plain)
    }
    
    private var shiftLastDayControls: some View {
        HStack {
            Button("Back") {
                dashboardManager.shiftLastDay(to: .yesterday)
            }
            
            Spacer()
            
            Text("\(dashboardManager.lastDay.formatted(date: .abbreviated, time: .omitted))")
            
            Spacer()
            
            Button("Forward") {
                dashboardManager.shiftLastDay(to: .tomorrow)
            }
        }
        .padding(16)
        .sensoryFeedback(.selection, trigger: dashboardManager.lastDay)
    }
    
}
