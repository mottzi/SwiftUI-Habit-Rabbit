import SwiftUI
import SwiftData
import AppData
import AppComponents

struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    
    @State private var endDay: Date = .now
    @State private var viewType: HabitCardType = .daily
    @State private var entriesDeleting: Set<Habit.Entry.ID> = []
    @State private var scrollDisabled = false
    
    @Query private var habits: [Habit]
    @Query private var values: [Habit.Value]
    
    var entries: [Habit.Entry] {
        habits.compactMap { habit in
            createEntry(for: habit)
        }
    }
    
    init(endDay: Date = .now) {
        let startDate = Calendar.current.date(byAdding: .day, value: -6, to: endDay)!
        _endDay = State(initialValue: endDay)
        _habits = Query(sort: \Habit.date)
        _values = Query(Habit.Value.filter(dateRange: startDate...endDay))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(entries.enumerated, id: \.element.id) { index, entry in
                        let isDeleting = isDeleting(entry: entry)
                        HabitCard(
                            entry: entry,
                            onValueChange: { updateValue(for: entry.habit.id, newValue: $0) }
                        )
                        .scaleEffect(isDeleting ? 0 : 1)
                        .frame(height: entry.mode == .monthly ? 350 : 230)
                        .contentShape(.contextMenuPreview, .rect(cornerRadius: 24))
                        .contextMenu { contextMenuButtons(for: entry) }
                        .offset(
                            x: isDeleting ? (index % 2 == 0 ? -250 : 250) : 0,
                            y: isDeleting ? 100 : 0
                        )
                    }
                }
                .padding()
                .navigationTitle("Habit Rabbit")
                .toolbar {
                    viewTypeButton
                    debugToolbar
                }
            }
            .animation(.default, value: habits)
            .animation(.default, value: viewType)
        }
    }
    
    var columns: [GridItem] {
        let column = GridItem(.flexible(), spacing: 16)
        return switch viewType {
            case .daily: [column, column]
            case .weekly, .monthly: [column]
        }
    }
}

extension ContentView {
    @ToolbarContentBuilder
    var viewTypeButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                ForEach(HabitCardType.allCases, id: \.self) { type in
                    Button("\(type.rawValue)", systemImage: type.icon) {
//                        withAnimation {
                            viewType = type
//                        }
                    }
                }
            } label: {
                HStack {
                    Text("\(viewType.rawValue)")
                    Image(systemName: "calendar.day.timeline.right")
                }
                .fontWeight(.bold)
                .foregroundStyle(colorScheme == .light ? .black : .white)
            }
        }
    }
}

extension ContentView {
    @ViewBuilder
    func contextMenuButtons(for entry: Habit.Entry) -> some View {
        randomizeContextButton(entry: entry)
        resetContextButton(entry: entry)
        deleteContextButton(entry: entry)
    }
    
    func randomizeContextButton(entry: Habit.Entry) -> some View {
        Button("Randomize", systemImage: "sparkles") {
            let randomValue = Int.random(in: 0...entry.habit.target * 2)
            updateValue(for: entry.habit.id, newValue: randomValue)
        }
    }
    
    func resetContextButton(entry: Habit.Entry) -> some View {
        Button("Reset", systemImage: "arrow.counterclockwise") {
            updateValue(for: entry.habit.id, newValue: 0)
        }
    }
    
    func deleteContextButton(entry: Habit.Entry) -> some View {
        Button("Delete", systemImage: "trash", role: .destructive) {
            delete(entry: entry)
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
            Text("Habits: \(habits.count)")
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
            try? modelContext.save()
        }
    }
    
    var randomizeDebugButton: some View {
        Button("Randomize All", systemImage: "sparkles") {
            for habit in habits {
                let randomValue = Int.random(in: 0...habit.target * 2)
                updateValue(for: habit.id, newValue: randomValue)
            }
        }
    }
    
    var resetValuesButton: some View {
        Button("Reset All", systemImage: "arrow.counterclockwise") {
            for habit in habits {
                updateValue(for: habit.id, newValue: 0)
            }
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
            delete(entry: firstEntry)
        }
    }
    
    var removeLastHabitEntryButton: some View {
        Button("Delete Last", systemImage: "trash", role: .destructive) {
            guard let lastEntry = entries.last else { return }
            delete(entry: lastEntry)
        }
    }
    
    var removeHabitsButton: some View {
        Button("Delete All", systemImage: "trash", role: .destructive) {
            try? modelContext.delete(model: Habit.self)
            try? modelContext.save()
        }
    }
}

extension ContentView {
    var valueLookup: [Habit.ID: [Date: Int]] {
        var lookup: [Habit.ID: [Date: Int]] = [:]
        
        for value in values {
            guard let habitID = value.habit?.id else { continue }
            let date = Calendar.current.startOfDay(for: value.date)
            
            if lookup[habitID] == nil {
                lookup[habitID] = [:]
            }
            lookup[habitID]?[date] = value.currentValue
        }
        
        return lookup
    }
    
    private func createEntry(for habit: Habit) -> Habit.Entry {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: endDay)
        
        // Get today's value efficiently
        let todayValue = valueLookup[habit.id]?[today] ?? 0
        
        // Get weekly values efficiently
        let weeklyValues = (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: offset - 6, to: endDay)!
            let dayDate = calendar.startOfDay(for: date)
            return valueLookup[habit.id]?[dayDate] ?? 0
        }
        
        return Habit.Entry(
            habit: habit,
            mode: viewType,
            dailyValue: todayValue,
            weeklyValues: weeklyValues
        )
    }
    
    private func updateValue(for habitID: Habit.ID, newValue: Int) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: endDay)
        
        // Find existing value or create new one
        if let existingValue = values.first(where: {
            $0.habit?.id == habitID && calendar.isDate($0.date, inSameDayAs: today)
        }) {
            existingValue.currentValue = newValue
        } else {
            guard let habit = habits.first(where: { $0.id == habitID }) else { return }
            let newValueEntry = Habit.Value(habit: habit, date: today, currentValue: newValue)
            modelContext.insert(newValueEntry)
        }
    }
    
    private func isDeleting(entry: Habit.Entry) -> Bool {
        entriesDeleting.contains(entry.id)
    }
    
    private func delete(entry: Habit.Entry) {
        Task {
            // Start card deletion animation
            try? await Task.sleep(nanoseconds: 10_000_000)
            withAnimation(.spring(duration: 0.8)) {
                _ = entriesDeleting.insert(entry.id)
            } completion: {
                _ = entriesDeleting.remove(entry.id)
            }
            
            // Delete entry and animate grid re-ordering
            try? await Task.sleep(nanoseconds: 10_000_000)
            modelContext.delete(entry.habit)
        }
    }
}

#Preview {
    ContentView(endDay: .now)
        .modelContainer(for: [Habit.self, Habit.Value.self], inMemory: true)
}
