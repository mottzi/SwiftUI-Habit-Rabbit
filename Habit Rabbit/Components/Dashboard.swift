import SwiftUI
import SwiftData

extension Habit {
    struct Dashboard: View {
        @Environment(\.colorScheme) var colorScheme
        @Environment(\.modelContext) var modelContext
        
        // time interval mode for all cards (daily | weekly | monthly)
        @State var mode: Habit.Card.Mode = .daily
        // end date for the time interval being displayed
        @State var lastDay: Date = .now.startOfDay
        
        @State private var managerCache: [Habit.ID: Habit.Card.Manager] = [:]
        @State private var managers: [Habit.Card.Manager] = []
        
        var body: some View {
            let _ = print("📊 Dashboard body evaluating with \(managerCache.count) habits")
            
            ScrollView {
                VStack(alignment: .center, spacing: 50){
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(managers.enumerated, id: \.element.habit.id) { index, manager in
                            Habit.Card(
                                manager: manager,
                                index: index,
                                onDelete: refreshManagers,
                            )
                        }
                    }
                    debugButton
                }
                .padding(16)
            }
            .navigationTitle("Habit Rabbit")
            .animation(.default, value: managerCache.count)
            .toolbar { modePicker }
            .onAppear { refreshManagers() }
            .onChange(of: mode) { refreshManagerModes() }
        }
        
        let columns = [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16),
        ]
    }
}

extension Habit.Dashboard {
    // synchronizes manager modes with global mode
    func refreshManagerModes() {
        managers.forEach { $0.updateMode(mode) }
    }
    
    // synchronize managers with database habits
    func refreshManagers() {
        print("📊 Synchronizing view models and habits ...")
        do {
            // create new cache
            var newManagerCache: [Habit.ID: Habit.Card.Manager] = [:]
            
            // fetch all habits, ordered by creation date
            let habits = try modelContext.fetch(FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.date)]))
            
            // synchronize cache with habits, creating managers only when necessary
            for habit in habits {
                // use cached manager for this habit if available
                if let manager = managerCache[habit.id] {
                    newManagerCache[habit.id] = manager
                    continue
                }
                // otherwise, create new manager for this habit
                print("Habit: \(habit.name)")
                print("    🧾 creating view model")
                let newManager = Habit.Card.Manager(
                    for: habit,
                    until: lastDay,
                    mode: mode,
                    in: modelContext
                )
                newManager.updateMode(mode)
                newManagerCache[habit.id] = newManager
            }
            
            // update cache
            self.managerCache = newManagerCache
            
            // update view models
            self.managers = habits.compactMap { habit in
                newManagerCache[habit.id]
            }
        } catch {
            print("Failed to fetch habits:", error)
        }
    }
}

extension Habit.Dashboard {
    // button to cycle through available time intervals
    var modePicker: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            ModePicker(
                width: 240,
                mode: $mode
            )
            .padding(.leading, 8)
            .sensoryFeedback(.selection, trigger: mode)
        }
    }
}

extension Habit.Dashboard { 
    // hamburger menu containing various debug actions
    var debugButton: some View {
        Menu {
            addExampleButton
            randomizeButton
            Divider()
            removeDBButton
            removeHabitsButton
        } label: {
            HStack(spacing: 16) {
                Image(systemName: "hammer.fill")
                    .foregroundStyle(colorScheme == .light ? .black : .white)
                    .frame(width: 64, height: 64)
                    .background {
                        Circle()
                            .fill(.quaternary)
                    }
                    .padding()
                
                Text("Habits: \(managers.count)")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary.opacity(0.7))
            }
        }
        .buttonStyle(.plain)
    }
    
    var removeDBButton: some View {
        Button("Kill Database", systemImage: "sparkle") {
            modelContext.container.deleteAllData()
            refreshManagers()
        }
    }
    
    // submenu for adding a specified number of example habits
    var addExampleButton: some View {
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
                        
                        modelContext.insert(habit: newHabit)
                    }
                    
                    try? modelContext.save()
                    refreshManagers()
                }
            }
        } label: {
            Label("Add", systemImage: "plus")
        }
    }
    
    var randomizeButton: some View {
        Button("Randomize all", systemImage: "sparkle") {
            managers.forEach {
                $0.createRandomizedHistory()
            }
        }
    }
    
    // button to delete all habits from the model context
    // will also delete all associated values of the habit
    var removeHabitsButton: some View {
        Button("Delete All", systemImage: "trash", role: .destructive) {
            try? modelContext.delete(model: Habit.self)
            try? modelContext.save()
            refreshManagers()// Refresh after deletion
        }
    }
}
