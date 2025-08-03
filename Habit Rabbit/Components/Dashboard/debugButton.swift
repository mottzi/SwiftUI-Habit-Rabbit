import SwiftUI

extension Habit.Dashboard {
    
    var debugButton: some View {
        Menu {
            addExampleButton
            randomizeButton
            resetAllButton
            Divider()
            removeDBButton
            removeHabitsButton
        } label: {
            HStack(spacing: 16) {
                Image(systemName: "hammer.fill")
                    .foregroundStyle(colorScheme == .light ? .black : .white)
                    .frame(width: 64, height: 64)
                    .background(Circle().fill(.quaternary))
                    .padding()
                
                Text("Habits: \(cardManagers.count)")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary.opacity(0.7))
            }
        }
        .buttonStyle(.plain)
    }
    
}

extension Habit.Dashboard {
    
    private var addExampleButton: some View {
        Menu {
            ForEach([1, 2, 4, 8, 20, 50, 100], id: \.self) { count in
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
                            target: template.target,
                            kind: template.kind
                        )
                        manager.modelContext.insert(habit: newHabit)
                    }
                    
                    try? manager.modelContext.save()
                    manager.refreshManagers()
                }
            }
        } label: {
            Label("Add Examples", systemImage: "plus")
        }
    }
    
    private var randomizeButton: some View {
        Button("Randomize All", systemImage: "sparkles") {
            cardManagers.forEach { $0.randomizeMonthlyValues() }
        }
    }
    
    private var resetAllButton: some View {
        Button("Reset All", systemImage: "0.circle") {
            cardManagers.forEach { $0.resetDailyValue() }
        }
    }
    
    private var removeDBButton: some View {
        Button("Kill Database", systemImage: "xmark", role: .destructive) {
            manager.modelContext.container.deleteAllData()
            manager.refreshManagers()
        }
    }
    
    private var removeHabitsButton: some View {
        Button("Delete All", systemImage: "trash", role: .destructive) {
            try? manager.modelContext.delete(model: Habit.self)
            try? manager.modelContext.save()
            manager.refreshManagers()
        }
    }
    
}
