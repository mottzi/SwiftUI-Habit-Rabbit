import SwiftUI
import SwiftData
import AppComponents

struct ContentView: View {
    var habitDate: Date
    @Environment(\.modelContext) private var modelContext
    
    @Query private var habits: [Habit]
    @Query private var values: [HabitValue]
    
    init(for date: Date) {
        self.habitDate = date
        
        var valuesQuery = FetchDescriptor<HabitValue>(
            predicate: HabitValue.dayFilter(for: date),
            sortBy: [SortDescriptor(\.habit.date)]
        )
        valuesQuery.relationshipKeyPathsForPrefetching = [\.habit]
        _values = Query(valuesQuery)
        _habits = Query(sort: \Habit.date)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(values.pairs, id: \.first?.id) { values in
                        HStack(spacing: 16) {
                            ForEach(values) { value in
                                HabitCard(
                                    habit: value.habit,
                                    habitValue: value
                                )
                            }
                            
                            if values.count < 2 { horizontalSpacer }
                        }
                    }
                }
                .padding()
                .navigationTitle("Habit Rabbit")
                .onChange(of: habits.count, initial: true) { insertDefaultValues(date: habitDate) }
            }
            .toolbar { debugToolbar }
        }
    }
}

extension ContentView {
    private func insertDefaultValues(date: Date) {
        let existingHabitIDs = Set(values.map { $0.habit.id } )
        
        for habit in habits {
            guard existingHabitIDs.contains(habit.id) == false else { continue }
            modelContext.insert(HabitValue(habit: habit, date: date))
            print("default value inserted for \(habit.id)")
        }
        
        if modelContext.hasChanges {
            try? modelContext.save()
        }
        
        print("default values checked")
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
            values.forEach { $0.currentValue = 0 }
            try? modelContext.save()
        }
    }
    
    var randomizeButton: some View {
        Button("", systemImage: "sparkles") {
            values.forEach { $0.currentValue = Int.random(in: 0...$0.habit.target * 2) }
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

