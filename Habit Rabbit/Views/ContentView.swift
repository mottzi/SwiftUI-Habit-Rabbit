import SwiftUI
import SwiftData
import AppData
import AppComponents

struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    
    @Query private var values: [Habit.Value]
    
    var entries: [Habit.Entry] {
        values.compactMap(\.asEntry)
    }
    
    @State private var entriesDeleting: Set<Habit.Entry.ID> = []
    
    init(day: Date) {
        _values = Query(Habit.Value.filter(day: day))
    }
    
    func triggerDeletion(of entry: Habit.Entry) {
        // context menu will start its revert state animation immediatly
        Task {
            // wait 0.01s ...
            try? await Task.sleep(nanoseconds: 10_000_000)
            // ... before starting card deletion animation
            withAnimation(.spring(duration: 0.8)) {
                _ = entriesDeleting.insert(entry.id)
            } completion: {
                _ = entriesDeleting.remove(entry.id)
            }
            
            // wait 0.01s ...
            try? await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds
            // ... defore deleting the actual entry
            modelContext.delete(entry.habit)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: twoColumns, spacing: 16) {
                    ForEach(entries.enumerated, id: \.element.id) { index, entry in
                        let isDeleting = entriesDeleting.contains(entry.id)
                        HabitCard(
                            habit: entry.habit,
                            value: Binding(
                                get: { entry.value.currentValue },
                                set: { entry.value.currentValue = $0 }
                            )
                        )
                        .geometryGroup()
                        .scaleEffect(isDeleting ? 0 : 1)
                        .contentShape(.contextMenuPreview, .rect(cornerRadius: 24))
                        .contextMenu { contextMenuButtons(entry: entry) }
                        .offset(
                            x: isDeleting ? (index % 2 == 0 ? -250 : 250) : 0,
                            y: isDeleting ? 100 : 0
                        )
                    }
                }
                .animation(.spring, value: entries.count)
                .padding(/*16*/)
                .navigationTitle("Habit Rabbit")
                .toolbar { debugToolbar }
            }
        }
    }
    
    let twoColumns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]
}

extension ContentView {
    @ViewBuilder
    func contextMenuButtons(entry: Habit.Entry) -> some View {
        randomizeContextButton(entry: entry)
        resetContextButton(value: entry.value)
        deleteContextButton(entry: entry)
    }
    
    func randomizeContextButton(entry: Habit.Entry) -> some View {
        Button("Randomize", systemImage: "sparkles") {
            entry.value.currentValue = Int.random(in: 0...entry.habit.target * 2)
        }
    }
    
    func resetContextButton(value: Habit.Value) -> some View {
        Button("Reset", systemImage: "arrow.counterclockwise") {
            value.currentValue = 0
        }
    }
    
    func deleteContextButton(entry: Habit.Entry) -> some View {
        Button("Delete", systemImage: "trash", role: .destructive) {
            triggerDeletion(of: entry)
        }
    }
}

extension ContentView {
    @ToolbarContentBuilder
    var debugToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) { debugCounter }
        ToolbarItem(placement: .topBarTrailing) { debugButton }
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
            removeAllDataButton
            removeFirstHabitEntryButton
            removeLastHabitEntryButton
            removeHabitsButton
        } label: {
            Image(systemName: "hammer.fill").foregroundStyle(colorScheme == .light ? .black : .white)
        }
    }
    
    var addExampleButton: some View {
        Button("Add", systemImage: "plus") {
            Habit.examples.forEach { modelContext.insert(habit: $0) }
            try? modelContext.save() // needed? [ ] yes, [ ] no
        }
    }
    
    var randomizeDebugButton: some View {
        Button("Randomize All", systemImage: "sparkles") {
            for value in values {
                guard let habit = value.habit else { continue}
                value.currentValue = Int.random(in: 0...habit.target * 2)
            }
        }
    }
    
    var resetValuesButton: some View {
        Button("Reset All", systemImage: "arrow.counterclockwise") {
            values.forEach { $0.currentValue = 0 }
        }
    }
    
    var removeAllDataButton: some View {
        Button("Kill Database", systemImage: "xmark", role: .destructive) {
            modelContext.container.deleteAllData()
        }
    }
    
    var removeFirstHabitEntryButton: some View {
        Button("Delete First", systemImage: "trash", role: .destructive) {
            guard let firstEntry = entries.first else { return }
//            modelContext.delete(first)
            triggerDeletion(of: firstEntry)
        }
    }
    
    var removeLastHabitEntryButton: some View {
        Button("Delete Last", systemImage: "trash", role: .destructive) {
            guard let lastEntry = entries.last else { return }
//            modelContext.delete(last)
            triggerDeletion(of: lastEntry)
        }
    }
    
    var removeHabitsButton: some View {
        Button("Delete All", systemImage: "trash", role: .destructive) {
            try? modelContext.delete(model: Habit.self)
            try? modelContext.save()
        }
    }
    
    var habitsCount: Int {
        guard let count = try? modelContext.fetchCount(FetchDescriptor<Habit>()) else { return 0 }
        return count
    }
}

#Preview {
    ContentView(day: .now)
        .modelContainer(for: [Habit.self, Habit.Value.self], inMemory: true)
}

