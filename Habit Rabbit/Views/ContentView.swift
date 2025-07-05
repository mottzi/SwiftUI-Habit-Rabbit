import SwiftUI
import SwiftData
import AppComponents

struct ContentView: View, HabitManager {
    @Environment(\.modelContext) var modelContext
    
    @Query var habitModels: [Habit]
    @Query var habitValues: [HabitValue]

    init() {
        let todayStart = Calendar.current.startOfDay(for: .now)
        let todayEnd = Calendar.current.date(byAdding: .day, value: 1, to: todayStart)!
        
        _habitModels = Query(filter: #Predicate<Habit> { habit in
            habit.dateCreated >= todayStart && habit.dateCreated < todayEnd
        })
        
        _habitValues = Query(filter: #Predicate<HabitValue> { habitValue in
            habitValue.dateCreated >= todayStart && habitValue.dateCreated < todayEnd
        })
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(habitModels.pairs, id: \.first?.id) { habits in
                        HStack(spacing: 16) {
                            ForEach(habits) { habit in
                                HabitCard(
                                    habit: habit,
                                    currentValue: binding(for: habit.id)
                                )
                            }
                            
                            if habits.count < 2 { horizontalSpacer }
                        }
                    }
                }
                .padding()
                .navigationTitle("Habit Rabbit")
                .onAppear { createMissingHabitValues() }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { removeHabitsButton }
                ToolbarItem(placement: .topBarLeading) { resetValuesButton }
                ToolbarItem(placement: .topBarLeading) { randomizeButton }
                ToolbarItem(placement: .topBarTrailing) { addExampleHabitButton }
            }
        }
    }
}

extension ContentView {
    var horizontalSpacer: some View {
        Color.clear.frame(maxWidth: .infinity)
    }
}

extension ContentView {
    var removeHabitsButton: some View {
        Button("", systemImage: "trash") {
            removeHabitData()
        }
    }
    
    var resetValuesButton: some View {
        Button("", systemImage: "0.circle") {
            resetHabitValues()
        }
    }
    
    var randomizeButton: some View {
        Button("", systemImage: "sparkles") {
            randomizeHabitValues()
        }
    }
    
    var addExampleHabitButton: some View {
        Button("", systemImage: "plus") {
            addExampleHabits()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Habit.self, HabitValue.self])
}
