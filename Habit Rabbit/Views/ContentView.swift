import SwiftUI
import SwiftData
import AppComponents

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    var habitDate: Date
    @Query private var allHabits: [Habit]
    @Query private var todayValues: [HabitValue]
    
    init(for date: Date) {
        self.habitDate = date
        _allHabits = Query(sort: \Habit.date)
        _todayValues = Query(filter: HabitValue.todayFilter(for: date))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(allHabits.pairs, id: \.first?.id) { habits in
                        HStack(spacing: 16) {
                            ForEach(habits) { habit in
                                HabitCard(
                                    habit: habit,
                                    habitValue: getTodayValue(of: habit, date: habitDate)
                                )
                            }
                            
                            if habits.count < 2 { horizontalSpacer }
                        }
                    }
                }
                .padding()
                .navigationTitle("Habit Rabbit")
                .onAppear { insertDefaultValues(date: habitDate) }
            }
            .toolbar { debugToolbar }
        }
    }
}

extension ContentView {
    private var lookup: [Habit.ID: HabitValue] {
        Dictionary(uniqueKeysWithValues: todayValues.map { ($0.habitID, $0) })
    }
    
    private func getTodayValue(of habit: Habit, date: Date) -> HabitValue {
        lookup[habit.id] ?? HabitValue(habit: habit, date: date)
    }
    
    private func insertDefaultValues(date: Date) {
        for habit in allHabits {
            guard lookup[habit.id] == nil else { continue }
            modelContext.insert(HabitValue(habit: habit, date: date))
        }
        
        if modelContext.hasChanges {
            try? modelContext.save()
        }
    }
}

extension ContentView {
    var horizontalSpacer: some View {
        Color.clear.frame(maxWidth: .infinity)
    }
    
    @ToolbarContentBuilder
    var debugToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) { removeHabitsButton }
        ToolbarItem(placement: .topBarLeading) { resetValuesButton }
        ToolbarItem(placement: .topBarLeading) { randomizeButton }
        ToolbarItem(placement: .topBarTrailing) { addExampleButton }
    }
    
    var removeHabitsButton: some View {
        Button("", systemImage: "trash") {
            try? modelContext.delete(model: Habit.self)
            try? modelContext.delete(model: HabitValue.self)
        }
    }
    
    var resetValuesButton: some View {
        Button("", systemImage: "0.circle") {
            todayValues.forEach { $0.currentValue = 0 }
            try? modelContext.save()
        }
    }
    
    var randomizeButton: some View {
        Button("", systemImage: "sparkles") {
            todayValues.forEach { $0.currentValue = Int.random(in: 0...$0.habit.target * 2) }
            try? modelContext.save()
        }
    }
    
    var addExampleButton: some View {
        Button("", systemImage: "plus") {
            for example in Habit.examples() {
                let value = HabitValue(habit: example, date: habitDate)
                modelContext.insert(example)
                modelContext.insert(value)
            }
            try? modelContext.save()
        }
    }
}


#Preview {
    ContentView(for: .now)
        .modelContainer(for: [Habit.self, HabitValue.self], inMemory: true)
}

