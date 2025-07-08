import SwiftUI
import SwiftData
import AppComponents

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var values: [HabitValue]

    init(for date: Date) {
        var valuesQuery = FetchDescriptor<HabitValue>(
            predicate: HabitValue.dayFilter(for: date),
            sortBy: [SortDescriptor(\HabitValue.habit.date)]
        )
        valuesQuery.relationshipKeyPathsForPrefetching = [\.habit]
        
        _values = Query(valuesQuery)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(values) {
                        @Bindable var value = $0
                        HabitCard(
                            habit: value.habit,
                            value: $value.currentValue
                        )
                    }
                }
                .padding()
                .navigationTitle("Habit Rabbit")
            }
            .toolbar { debugToolbar }
        }
    }
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]
}

extension ContentView {
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
                modelContext.insert(habit: example)
            }
            try? modelContext.save()
        }
    }
}

#Preview {
    ContentView(for: .now)
        .modelContainer(for: [Habit.self, HabitValue.self], inMemory: true)
}

