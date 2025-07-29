import SwiftUI
import SwiftData

extension Habit {
    struct Dashboard: View {
        @Environment(\.colorScheme) var colorScheme
        
        @Bindable var manager: Habit.Dashboard.Manager
        var cardManagers: [Habit.Card.Manager] { manager.cardManagers }
        
        var body: some View {
            ScrollView {
                VStack(alignment: .center, spacing: 50) {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(cardManagers.enumerated, id: \.element.habit.id) { index, cardManager in
                            Habit.Card(
                                manager: cardManager,
                                index: index,
                                onDelete: manager.refreshManagers
                            )
                        }
                    }
                    debugButton
                }
                .padding(16)
            }
            .navigationTitle("Habit Rabbit")
            .animation(.default, value: cardManagers.count)
            .toolbar { modePicker }
        }
        
        private let columns = [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16),
        ]
    }
}

extension Habit.Dashboard {
    private var modePicker: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            ModePicker(
                width: 240,
                mode: $manager.mode
            )
            .padding(.leading, 8)
            .sensoryFeedback(.selection, trigger: manager.mode)
        }
    }
}
extension Habit.Dashboard {
    private var debugButton: some View {
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
    
    private var removeDBButton: some View {
        Button("Kill Database", systemImage: "xmark", role: .destructive) {
            manager.modelContext.container.deleteAllData()
            manager.refreshManagers()
        }
    }
    
    private var addExampleButton: some View {
        Menu {
            ForEach([1, 2, 4, 8, 20, 50, 100], id: \.self) { count in
                Button("\(count)") {
                    let templates = Habit.examples
                    guard !templates.isEmpty else { return }
                    
                    for i in 0..<count {
                        let template = templates[i % templates.count]
                        let newHabit = Habit(name: template.name, unit: template.unit, icon: template.icon, color: template.color, target: template.target, kind: template.kind)
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
            cardManagers.forEach {
                $0.createRandomizedHistory()
            }
        }
    }
    
    private var resetAllButton: some View {
        Button("Reset All", systemImage: "0.circle") {
            cardManagers.forEach {
                $0.resetLastDayValue()
            }
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
