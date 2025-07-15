import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    
    @State var endDay: Date = .now
    @State var viewType: HabitCardType = .daily
    @State private var entriesDeleting: [Habit.ID: CGSize] = [:]
    
    @Query var habits: [Habit]
    
    init(endDay: Date = .now) {
        _endDay = State(initialValue: endDay)
        _habits = Query(sort: \Habit.date)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(habits) { habit in
                        let isDeleting = isDeleting(habit: habit)
                        let offset = deletionOffset(for: habit, isDeleting: isDeleting)
                        Habit.Card(habit: habit, endDay: endDay, viewType: viewType, onDelete: { delete(habit: habit) }, isDeleting: isDeleting, deletionOffset: offset)
                    }
                }
                .padding()
                .navigationTitle("Habit Rabbit")
                .toolbar {
                    modeButton
                    debugToolbar
                }
            }
            .animation(.default, value: habits.count)
            .animation(.default, value: viewType)
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
    
    private func delete(habit: Habit) {
        Task {
            try? await Task.sleep(nanoseconds: 10_000_000) // Initial delay
            let offset = calculateDeletionOffset(for: habit)
            withAnimation(.spring(duration: 0.8)) {
                entriesDeleting[habit.id] = offset
            } completion: {
                entriesDeleting.removeValue(forKey: habit.id)
            }
            
            try? await Task.sleep(nanoseconds: 10_000_000) // Delay before model deletion
            modelContext.delete(habit)
        }
    }
    
    private func isDeleting(habit: Habit) -> Bool {
        entriesDeleting.keys.contains(habit.id)
    }
    
    private func calculateDeletionOffset(for habit: Habit) -> CGSize {
        guard let index = habits.firstIndex(of: habit) else { return .zero }
        let amount = viewType == .daily ? 250 : 500
        let adjustedSide = (index % 2 == 0 ? -amount : amount)
        return CGSize(width: adjustedSide, height: 100)
    }
    
    private func deletionOffset(for habit: Habit, isDeleting: Bool) -> CGSize {
        isDeleting ? entriesDeleting[habit.id] ?? .zero : .zero
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
        }
        .font(.footnote)
        .fontWeight(.semibold)
        .foregroundStyle(.primary.opacity(0.7))
    }
    
    var debugButton: some View {
        Menu {
            addExampleButton
            Divider()
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
