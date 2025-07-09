import SwiftUI
import SwiftData
import AppData
import AppComponents

struct ContentView: View{
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    @Query private var values: [HabitValue]
    
    var entries: [(Habit, HabitValue)] {
        values.compactMap(\.withHabit)
    }
    
    init(day date: Date) {
        _values = Query(HabitValue.filter(day: date))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(entries, id: \.0.id) { (habit, value) in
                        @Bindable var value = value
                        HabitCard(
                            name: habit.name,
                            unit: habit.unit,
                            target: habit.target,
                            icon: habit.icon,
                            color: habit.color,
                            value: $value.currentValue
                        )
                        .contentShape(.contextMenuPreview, .rect(cornerRadius: 24))
                        .contextMenu {
                            Button("Randomize", systemImage: "sparkles") {
                                value.currentValue = Int.random(in: 0...habit.target * 2)
                            }
                            Button("Reset", systemImage: "arrow.counterclockwise") {
                                value.currentValue = 0
                            }
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                modelContext.delete(habit)
                            }
                        }
                    }
                }
                .padding()
                .navigationTitle("Habit Rabbit")
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { debugCounter }
                ToolbarItem(placement: .topBarTrailing) { debugButton }
            }
        }
    }
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]
}

extension ContentView {
    var habitsCount: Int {
        guard let count = try? modelContext.fetchCount(FetchDescriptor<Habit>()) else { return 0 }
        return count
    }

    @ViewBuilder
    var debugCounter: some View {
        HStack {
            Text("Habits: \(habitsCount)")
            Text("Values: \(values.count)")
        }
        .font(.footnote)
        .fontWeight(.semibold)
        .foregroundStyle(.primary.opacity(0.7))
    }
    
    var debugButton: some View {
        Menu {
            addExampleButton
            Divider()
            randomizeDebugButton
            resetValuesButton
            Divider()
            removeHabitsButton
        } label: {
            Image(systemName: "hammer.fill").foregroundStyle(colorScheme == .light ? .black : .white)
        }
    }
    
    var addExampleButton: some View {
        Button("Add", systemImage: "plus") {
            Habit.examples.forEach { modelContext.insert(habit: $0) }
            try? modelContext.save()
        }
    }
    
    var randomizeDebugButton: some View {
        Button("Randomize", systemImage: "sparkles") {
            for value in values {
                guard let habit = value.habit else { continue}
                value.currentValue = Int.random(in: 0...habit.target * 2)
            }
        }
    }
    
    var resetValuesButton: some View {
        Button("Reset", systemImage: "arrow.counterclockwise") {
            values.forEach { $0.currentValue = 0 }
        }
    }
    
    var removeHabitsButton: some View {
        Button("Delete", systemImage: "trash", role: .destructive) {
            try? modelContext.delete(model: Habit.self)
            try? modelContext.save()
        }
    }
}

#Preview {
    ContentView(day: .now)
        .modelContainer(for: [Habit.self, HabitValue.self], inMemory: true)
}

