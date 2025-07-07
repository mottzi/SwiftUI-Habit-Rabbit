import SwiftUI
import SwiftData
import AppComponents

struct ContentView: View {
    var habitDate: Date
    @Environment(\.modelContext) private var modelContext
    
    @Query private var allHabits: [Habit]
    @Query private var todayValues: [HabitValue]
    @State private var lookup: [Habit.ID: HabitValue] = [:]
    
    private var loadedHabits: [Habit] { allHabits.filter { lookup[$0.id] != nil } }
    
    init(for date: Date) {
        self.habitDate = date
        _allHabits = Query(sort: \Habit.date)
        _todayValues = Query(filter: HabitValue.todayFilter(for: date))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(loadedHabits.pairs, id: \.first?.id) { habits in
                        HStack(spacing: 16) {
                            ForEach(habits) { habit in
                                HabitCard(
                                    habit: habit,
                                    habitValue: lookupValue(of: habit)
                                )
                            }
                            
                            if habits.count < 2 { horizontalSpacer }
                        }
                    }
                }
                .padding()
                .navigationTitle("Habit Rabbit")
                .onChange(of: allHabits.map(\.id), initial: true) {
                    updateLookup()
                    insertDefaultValues(date: habitDate)
                }
            }
            .toolbar { debugToolbar }
        }
    }
}

extension ContentView {
    private func updateLookup() {
        lookup = Dictionary(uniqueKeysWithValues: todayValues.map { ($0.habitID, $0) })
        print("Lookup updated. Current lookup count: \(lookup.count)")
    }
    
    private func lookupValue(of habit: Habit) -> HabitValue {
        guard let value = lookup[habit.id] else {
            print("WARNING: No HabitValue found in lookup for '\(habit.name)' (ID: \(habit.id)).")
            return HabitValue(habit: habit, date: habitDate)
        }
        
        return value
    }
    
    private func insertDefaultValues(date: Date) {
        // we check against `todayValues` directly to see what's missing.
        let habitValueHabitIDs = Set(todayValues.map { $0.habitID } )
        
        for habit in allHabits {
            // skip if habit.id is found in todayValues [HabitValue.habitID]
            guard habitValueHabitIDs.contains(habit.id) == false else { continue }
            modelContext.insert(HabitValue(habit: habit, date: date))
            print("previously not existing HabitValue inserted for \(habit.id)")
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

