import SwiftUI
import SwiftData

extension Habit {
    // primary view that displays a 2 column grid of habit cards
    struct Dashboard: View {
        @Environment(\.colorScheme) var colorScheme
        @Environment(\.modelContext) var modelContext
        
        // time interval mode for all cards (daily | weekly | monthly)
        @State var mode: Habit.Card.Mode = .daily
        // end date for the time interval being displayed
        @State var lastDay: Date = .now.startOfDay
        // fetches all habits sorted by creation date
        @Query(sort: \Habit.date) var habits: [Habit]
        
        var body: some View {
            ScrollView {
                VStack(spacing: 0) {
                    ModePicker(
                        width: 240,
                        mode: $mode
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.leading, 4)
                    
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(habits.enumerated, id: \.element.id) { index, habit in
                            Habit.Card(
                                habit: habit,
                                lastDay: lastDay,
                                mode: mode,
                                index: index
                            )
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Habit Rabbit")
            .animation(.default, value: habits.count)
            .toolbar {
                //modeButton
                debugToolbar
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
    var modeButton: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            ModePicker(
                width: 140,
                mode: $mode
            )
        }
    }
}

extension Habit.Dashboard {
    struct ModePicker: View {
        var width: CGFloat
        @Binding var mode: Habit.Card.Mode
        
        typealias Mode = Habit.Card.Mode
        
        var body: some View {
            HStack(spacing: 0) {
                ForEach(Habit.Card.Mode.allCases, id: \.self) { item in
                    Button {
                        mode = mode == item ? mode.next : item
                    } label: {
                        Text(item.rawValue)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(mode == item ? .primary : .secondary)
                            .fontWeight(mode == item ? .bold : .medium)
                    }
                    .buttonStyle(.plain)
                    .contentShape(.rect)
                    .frame(width: width / 3)
                    .padding(.vertical, 6)
                }
            }
            .background {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .frame(width: width / 3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .offset(x: CGFloat(Mode.allCases.firstIndex(of: mode) ?? 0) * (width / 3), y: 0)
                    .animation(.spring(duration: 0.62), value: mode)
            }
            .frame(width: width)
        }
    }
}

extension Habit.Dashboard {
    @ToolbarContentBuilder
    var debugToolbar: some ToolbarContent {
        // ToolbarItem(placement: .topBarLeading) { debugCounter }
        ToolbarItem(placement: .topBarTrailing) { debugButton }
    }
    
    // view that displays the current number of habits
    var debugCounter: some View {
        HStack {
            Text("Habits: \(habits.count)")
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
            removeHabitsButton
        } label: {
            Image(systemName: "hammer.fill")
                .foregroundStyle(colorScheme == .light ? .black : .white)
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
                }
            }
        } label: {
            Label("Add", systemImage: "plus")
        }
    }
    
    var randomizeButton: some View {
        Button("Randomize all", systemImage: "sparkle") {
//            modelContext.insert(habit: Habit.examples[0])
//            modelContext.insert(habit: Habit.examples[1])
//            try? modelContext.save()
            // generate array of the last 30 day dates
            let dates = (0..<30).compactMap { offset in
                Calendar.current.date(byAdding: .day, value: -offset, to: lastDay)
            }
            
            // fetch all existing habit values in the date range
            let predicate = #Predicate<Habit.Value> { $0.date >= dates.last! && $0.date <= dates.first! }
            let existing = (try? modelContext.fetch(FetchDescriptor(predicate: predicate))) ?? []
            
            // create efficient lookup structure
            var lookup: [Habit.ID: [Date: Habit.Value]] = [:]
            for value in existing {
                guard let habitId = value.habit?.id else { continue }
                lookup[habitId, default: [:]][value.date] = value
            }
            
            // process each habit for each date
            for habit in habits {
                for date in dates {
                    let randomValue = switch habit.kind {
                        case .good: Int.random(in: 0...habit.target * 2)
                        case .bad: Int.random(in: 0...habit.target + 1)
                    }
                    
                    // check if value already exists in lookup
                    if let existingValue = lookup[habit.id]?[date] {
                        // update existing value in memory
                        existingValue.currentValue = randomValue
                    } else {
                        // create new value and add to context
                        modelContext.insert(Habit.Value(habit: habit, date: date, currentValue: randomValue))
                    }
                }
            }
            
            // single database save operation for all changes
            try? modelContext.save()
        }
    }
    
    // button to delete all habits from the model context
    // will also delete all associated values of the habit
    var removeHabitsButton: some View {
        Button("Delete All", systemImage: "trash", role: .destructive) {
            try? modelContext.delete(model: Habit.self)
            try? modelContext.save()
        }
    }
}
