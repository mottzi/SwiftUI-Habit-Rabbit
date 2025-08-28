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
                    .safeAreaInset(edge: .top) { modePicker }
                }
                .animation(.default, value: cardManagers.count)
                .sheet(isPresented: $presentAddSheet) { AddHabitSheet() }
                .overlay(alignment: .bottomTrailing) { debugButton }
                .navigationTitle("Habit Rabbit")
                .navigationBarTitleDisplayMode(dashboardManager.useInlineNavTitle ? .inline : .automatic)
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
    
    private var modePicker: some View {
        VStack(spacing: 16) {
            ModePicker(
                width: 240,
                mode: dashboardManager.mode,
                onSelection: { mode in
                    dashboardManager.updateMode(to: mode)
                }
            )
            .sensoryFeedback(.selection, trigger: dashboardManager.mode)
            
            Text(formattedDate(dashboardManager.lastDay))
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .padding(.top, 4)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.preferred
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private var addHabitButton: some ToolbarContent {
        ToolbarItem {
            Button("Add Habit", systemImage: "plus") {
                presentAddSheet = true
            }
            .buttonBorderShape(.circle)
            .buttonStyle(.bordered)
            .fontWeight(.semibold)
        }
    }
    
//    private var shiftLastDayControls: some View {
//        HStack {
//            Button("Back") {
//                dashboardManager.shiftLastDay(to: .yesterday)
//            }
//            
//            Spacer()
//            
//            Text("\(dashboardManager.lastDay.formatted(date: .abbreviated, time: .omitted))")
//            
//            Spacer()
//            
//            Button("Forward") {
//                dashboardManager.shiftLastDay(to: .tomorrow)
//            }
//        }
//        .padding(16)
//        .sensoryFeedback(.selection, trigger: dashboardManager.lastDay)
//    }
    
}
