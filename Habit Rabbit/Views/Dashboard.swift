import SwiftUI
import SwiftData

extension Habit {
    struct Dashboard: View {
        @Environment(\.colorScheme) private var colorScheme
        @Environment(\.modelContext) private var modelContext
        
        @Query(sort: \Habit.date) var habits: [Habit]
        @State var lastDay: Date = .now
        @State var mode: Habit.Card.Mode = .daily
        
        var body: some View {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(habits.enumerated, id: \.element.id) { index, habit in
                        Habit.Card(
                            habit: habit,
                            day: lastDay,
                            mode: mode,
                            index: index,
                        )
                    }
                }
                .padding(16)
            }
            .navigationTitle("Habit Rabbit")
            .toolbar {
                modeButton
                debugToolbar
            }
            .animation(.default, value: habits.count)
            .animation(.default, value: mode)
        }
        
        let columns = [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]
    }
}

extension Habit.Dashboard {
    @ToolbarContentBuilder
    var modeButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                mode = mode.next
            } label: {
                HStack(spacing: 0) {
                    Text("\(mode.rawValue)")
                        .frame(minWidth: 80)
                    Image(systemName: "calendar.day.timeline.right")
                }
                .frame(minWidth: 120)
                .fontWeight(.bold)
                .foregroundStyle(colorScheme == .light ? .black : .white)
            }
        }
    }
}

extension Habit.Dashboard {
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
