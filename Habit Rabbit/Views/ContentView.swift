import SwiftUI
import AppComponents

struct ContentView: View {
    @State private var habitModels: [Habit] = []
    @State private var habitValues: [Habit.ID: Int] = [:]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(habitModels.pairs, id: \.first?.id) { habits in
                        HStack(spacing: 16) {
                            ForEach(habits) { habit in
                                HabitCard(
                                    habit: habit,
                                    currentValue: binding(for: habit.id)
                                )
                            }
                            
                            if habits.count < 2 { horizontalSpacer }
                        }
                    }
                }
                .padding()
                .navigationTitle("Habit Rabbit")
                .onAppear { loadHabitData() }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { removeHabitsButton }
                ToolbarItem(placement: .topBarLeading) { resetValuesButton }
                ToolbarItem(placement: .topBarLeading) { randomizeButton }
                ToolbarItem(placement: .topBarTrailing) { addExampleHabitButton }
            }
        }
    }
}

extension ContentView {
    var horizontalSpacer: some View {
        Color.clear.frame(maxWidth: .infinity)
    }
}

extension ContentView {
    var removeHabitsButton: some View {
        Button("", systemImage: "trash") {
            removeHabitData()
        }
    }
    
    var resetValuesButton: some View {
        Button("", systemImage: "0.circle") {
            resetHabitValues()
        }
    }
    
    var randomizeButton: some View {
        Button("", systemImage: "sparkles") {
            randomizeHabitValues()
        }
    }
    
    var addExampleHabitButton: some View {
        Button("", systemImage: "plus") {
            let examples = Habit.examples()
            let randomExamples = examples.randomElements(count: Int.random(in: 1...examples.count))
            
            for habit in randomExamples {
                habitValues[habit.id] = 0
                habitModels.append(habit)
            }
            saveHabitData()
        }
    }
}

extension ContentView {
    private func binding(for habitID: Habit.ID) -> Binding<Int> {
        Binding(
            get: {
                habitValues[habitID] ?? 0
            },
            set: { newValue in
                habitValues[habitID] = newValue
                saveHabitValues()
            }
        )
    }
    
    private func loadHabitData() {
        loadHabitModels()
        loadHabitValues()
    }
    
    private func loadHabitModels() {
        guard let data = UserDefaults.standard.data(forKey: "habitModels") else { return }
        guard let decoded = try? JSONDecoder().decode([Habit].self, from: data) else { return }
        habitModels = decoded
    }
    
    private func loadHabitValues() {
        guard let data = UserDefaults.standard.data(forKey: "habitValues") else { return }
        guard let decoded = try? JSONDecoder().decode([Habit.ID: Int].self, from: data) else { return }
        habitValues = decoded
    }
    
    private func saveHabitData() {
        saveHabitModels()
        saveHabitValues()
    }
    
    private func saveHabitModels() {
        guard let data = try? JSONEncoder().encode(habitModels) else { return }
        UserDefaults.standard.set(data, forKey: "habitModels")
    }
    
    private func saveHabitValues() {
        guard let data = try? JSONEncoder().encode(habitValues) else { return }
        UserDefaults.standard.set(data, forKey: "habitValues")
    }
    
    private func removeHabitData() {
        habitModels = []
        saveHabitModels()
        
        habitValues = [:]
        saveHabitValues()
    }
    
    private func resetHabitValues() {
        habitValues = habitValues.mapValues { _ in 0 }
        saveHabitValues()
    }
    
    private func randomizeHabitValues() {
        let habitTargets = Dictionary(uniqueKeysWithValues: habitModels.map { ($0.id, $0.target) })
        
        for habitID in habitValues.keys {
            guard let target = habitTargets[habitID] else { continue }
            habitValues[habitID] = Int.random(in: 0...(target * 2))
        }
        
        saveHabitValues()
    }
}

#Preview { ContentView() }
