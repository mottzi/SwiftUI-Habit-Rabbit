import SwiftUI
import SwiftData

struct ContentView: HabitManaging, View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    
    @State var endDay: Date = .now
    @State var viewType: HabitCardType = .daily
    @State var valueLookup: [Habit.ID: [Date: Habit.Value]] = [:]
    @State private var entriesDeleting: Set<Habit.Entry.ID> = []
    
    @Query var habits: [Habit]
    @Query var values: [Habit.Value]
    
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
                        Habit.Card(entry: entry)
                            .scaleEffect(isDeleting ? 0 : 1)
                            .frame(height: entry.mode == .monthly ? 350 : 230)
                            .contentShape(.contextMenuPreview, .rect(cornerRadius: 24))
                            .contextMenu { contextMenuButtons(for: entry) }
                            .offset(deletionOffset(for: index, isDeleting: isDeleting))
                    }
                }
                .padding()
                .navigationTitle("Habit Rabbit")
                .toolbar {
                    modeButton
                    debugToolbar
                }
            }
            .animation(.default, value: entries.count)
            .animation(.default, value: viewType)
            .onChange(of: values, initial: true) { valueLookup = updatedValueLookup() }
        }
    }
}

extension ContentView {
    var columns: [GridItem] {
        let column = GridItem(.flexible(), spacing: 16)
        return switch viewType {
            case .daily: [column, column]
            case .weekly, .monthly: [column]
        }
    }
    
    private func delete(entry: Habit.Entry) {
        Task {
            try? await Task.sleep(nanoseconds: 10_000_000)
            withAnimation(.spring(duration: 0.8)) {
                _ = entriesDeleting.insert(entry.id)
            } completion: {
                _ = entriesDeleting.remove(entry.id)
            }
            
            try? await Task.sleep(nanoseconds: 10_000_000)
            modelContext.delete(entry.habit)
        }
    }
    
    private func isDeleting(entry: Habit.Entry) -> Bool {
        entriesDeleting.contains(entry.id)
    }
    
    private func deletionOffset(for index: Int, isDeleting: Bool) -> CGSize {
        guard isDeleting else { return CGSize(width: 0, height: 0) }
        let amount = viewType == .daily ? 250 : 500
        let adjustedSide = (index % 2 == 0 ? -amount : amount)
        return CGSize(width: adjustedSide, height: 100)
    }
}

extension ContentView {
    @ToolbarContentBuilder
    var modeButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                ForEach(HabitCardType.allCases, id: \.self) { type in
                    Button("\(type.rawValue)", systemImage: type.icon) {
                        viewType = type
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
            getTodayValue(of: entry.habit)?.currentValue = randomValue
        }
    }
    
    func resetContextButton(entry: Habit.Entry) -> some View {
        Button("Reset", systemImage: "arrow.counterclockwise") {
            getTodayValue(of: entry.habit)?.currentValue = 0
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
        Menu {
            ForEach([1, 4, 8, 20, 50, 100], id: \.self) { count in
                Button("\(count)") {
                    let templates = Habit.examples
                    guard !templates.isEmpty else { return }
                    
                    for i in 0..<count {
                        let template = templates[i % templates.count]
                        
                        let newHabit = Habit(
                            name: template.name,
                            unit: template.unit,
                            icon: template.icon,
                            color: template.color,
                            target: template.target
                        )
                        
                        modelContext.insert(habit: newHabit)
                    }
                    
                    try? modelContext.save()
                }
            }
        } label: {
            Label("Add", systemImage: "plus")
        }
    }
    
    var randomizeDebugButton: some View {
        Button("Randomize All", systemImage: "sparkles") {
            for habit in habits {
                let randomValue = Int.random(in: 0...habit.target * 2)
                getTodayValue(of: habit)?.currentValue = randomValue
            }
        }
    }
    
    var resetValuesButton: some View {
        Button("Reset All", systemImage: "arrow.counterclockwise") {
            for habit in habits {
                getTodayValue(of: habit)?.currentValue = 0
            }
        }
    }
    
    var removeAllDataButton: some View {
        Button("Kill Database", systemImage: "xmark", role: .destructive) {
            modelContext.container.deleteAllData()
        }
    }
    
    var removeFirstHabitEntryButton: some View {
        Button("Delete First", systemImage: "text.line.first.and.arrowtriangle.forward", role: .destructive) {
            guard let firstEntry = entries.first else { return }
            delete(entry: firstEntry)
        }
    }
    
    var removeLastHabitEntryButton: some View {
        Button("Delete Last", systemImage: "text.line.last.and.arrowtriangle.forward", role: .destructive) {
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

#Preview {
    ContentView(endDay: .now)
        .modelContainer(for: [Habit.self, Habit.Value.self], inMemory: true)
}
