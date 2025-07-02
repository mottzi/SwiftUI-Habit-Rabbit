import SwiftUI
import AppComponents

extension Array {
    func chunks(of size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
    
    func randomElements(count n: Int) -> [Element] {
        guard n > 0 else { return [] }
        return Array(shuffled().prefix(n))
    }
}

struct ContentView: View {
    @State private var habits: [Habit] = []
    @State private var habitValues: [Habit.ID: Int] = [:]
    
//    let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(habits.chunks(of: 2), id: \.first?.id) { habits in
                        HStack(spacing: 16) {
                            ForEach(habits) { habit in
                                HabitCard(
                                    habit: habit,
                                    habitCardType: .barChart,
                                    currentValue: Binding(
                                        get: { habitValues[habit.id] ?? 0 },
                                        set: { habitValues[habit.id] = $0 }
                                    )
                                )
                            }
                            
                            if habits.count < 2 {
                                Color.clear.frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
//                // animation glitch (triggering delayed off screen animations on scroll)
//                LazyVGrid(columns: gridColumns, spacing: 16) {
//                    ForEach(habits) { habit in
//                        HabitCard(
//                            habit: habit,
//                            habitCardType: .barChart,
//                            currentValue: Binding(
//                                get: { habitValues[habit.id] ?? 0 },
//                                set: { habitValues[habit.id] = $0 }
//                            )
//                        )
//                    }
//                }
                .padding()
                .navigationTitle("Habit Rabbit")
                .onAppear {
                    loadHabits()
                    loadHabitValues()
                }
                .onChange(of: habitValues) {
                    saveHabitValues()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("", systemImage: "trash") {
                        removeHabits()
                        removeHabitValues()
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("", systemImage: "0.circle") {
                        resetHabitValues()
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("", systemImage: "sparkles") {
                        randomizeHabitValues()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("", systemImage: "plus") {
                        let examples = Habit.examples()
                        let randomExamples = examples.randomElements(count: Int.random(in: 1...examples.count))
                        
                        for habit in randomExamples {
                            habitValues[habit.id] = 0
                            habits.append(habit)
                            saveHabits()
                        }
                    }
                }
            }
        }
    }
}

extension ContentView {
    private func removeHabits() {
        habits = []
        saveHabits()
    }
    
    private func randomizeHabitValues() {
        for key in habitValues.keys {
            if let habit = habits.first(where: { $0.id == key }) {
                habitValues[key] = Int.random(in: 0...(habit.target * 2))
            }
        }
    }
    
    private func resetHabitValues() {
        habitValues = habitValues.mapValues { _ in 0 }
        saveHabitValues()
    }
    
    private func removeHabitValues() {
        habitValues = [:]
        saveHabitValues()
    }
    
    private func loadHabits() {
        guard let data = UserDefaults.standard.data(forKey: "habits") else { return }
        let s = try? JSONDecoder().decode([Habit].self, from: data)
        
        habits = s ?? []
    }
    
    private func saveHabits() {
        guard let data = try? JSONEncoder().encode(habits) else { return }
        UserDefaults.standard.set(data, forKey: "habits")
    }
    
    private func loadHabitValues() {
        guard let data = UserDefaults.standard.data(forKey: "habitValues") else { return }
        let s = try? JSONDecoder().decode([UUID: Int].self, from: data)
        
        habitValues = s ?? [:]
    }
    
    private func saveHabitValues() {
        guard let data = try? JSONEncoder().encode(habitValues) else { return }
        UserDefaults.standard.set(data, forKey: "habitValues")
    }
}

extension View {
    func debug(_ color: Color? = nil, _ width: CGFloat? = nil) -> some View {
        self.border(color ?? .orange, width: width ?? 2)
    }
}

#Preview { ContentView() }
