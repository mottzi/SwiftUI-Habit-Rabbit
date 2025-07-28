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
                VStack(spacing: 0) {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(managers.enumerated, id: \.element.habit.id) { index, viewModel in
                            Habit.Card(
                                manager: viewModel,
                                mode: mode,
                                index: index,
                                onDelete: {
                                    refreshManagers()
                                }
                            )
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Habit Rabbit")
            .animation(.default, value: managerCache.count)
            .task {
                refreshManagers()
            }
            .toolbar {
                modePicker
                //debugToolbar
            }
        }
        
        // ADD: The reconciliation function to manage ViewModel lifecycle.
        func refreshManagers() {
            print("📊 Fetching habits to reconcile view models ...")
            do {
                // create new cache
                var newManagerCache: [Habit.ID: Habit.Card.Manager] = [:]
                
                // fetch all habits, ordered by creation date
                let habits = try modelContext.fetch(FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.date)]))
                
                // recreate cache, creating managers only when necessary
                for habit in habits {
                    // use cached manager for this habit if available
                    if let manager = managerCache[habit.id] {
                        newManagerCache[habit.id] = manager
                        continue
                    }
                    // otherwise, create new manager for this habit
                    print("🧾 \(habit.name): creating view model")
                    newManagerCache[habit.id] = Habit.Card.Manager(
                        modelContext: modelContext,
                        habit: habit,
                        lastDay: lastDay
                    )
                }
                
                // update cache
                self.managerCache = newManagerCache
                
                // Step 3: Create the final, ordered array for the view to use.
                // This is guaranteed to be consistent because we just reconciled the cache.
                self.managers = habits.compactMap { habit in
                    newManagerCache[habit.id]
                }
                
            } catch {
                print("Failed to fetch habits:", error)
            }
        }
        
        let columns = [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16),
        ]
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
    var debugToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) { debugButton }
    }
    
    // view that displays the current number of habits
    var debugCounter: some View {
        HStack {
            Text("Habits: \(managers.count)")
        }
        .font(.footnote)
        .fontWeight(.semibold)
        .foregroundStyle(.primary.opacity(0.7))
    }
    
    // hamburger menu containing various debug actions
    var debugButton: some View {
        Menu {
            addExampleButton
            randomizeButton
            Divider()
            removeDBButton
            removeHabitsButton
        } label: {
            Image(systemName: "hammer.fill")
                .foregroundStyle(colorScheme == .light ? .black : .white)
        }
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
