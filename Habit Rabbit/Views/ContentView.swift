import SwiftUI
import AppComponents

struct ContentView: View {
    @State private var habitModels: [Habit] = []
    @State private var habitValues: [Habit.ID: Int] = [:]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(habitModels.chunks(of: 2), id: \.first?.id) { habits in
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
                .padding()
                .navigationTitle("Habit Rabbit")
                .onAppear {
                    loadHabitModels()
                    loadHabitValues()
                }
                .onChange(of: habitValues) {
                    saveHabitValues()
                }
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
    var removeHabitsButton: some View {
        Button("", systemImage: "trash") {
            removeHabitModels()
            removeHabitValues()
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
                saveHabitModels()
            }
        }
    }
}

extension ContentView {
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
        guard let decoded = try? JSONDecoder().decode([UUID: Int].self, from: data) else { return }
        habitValues = decoded
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
        removeHabitModels()
        removeHabitValues()
    }
    
    private func removeHabitModels() {
        habitModels = []
        saveHabitModels()
    }
    
    private func removeHabitValues() {
        habitValues = [:]
        saveHabitValues()
    }
    
    private func resetHabitValues() {
        habitValues = habitValues.mapValues { _ in 0 }
        saveHabitValues()
    }
    
    private func randomizeHabitValues() {
        for key in habitValues.keys {
            if let habit = habitModels.first(where: { $0.id == key }) {
                habitValues[key] = Int.random(in: 0...(habit.target * 2))
            }
        }
    }
}

extension View {
    func debug(_ color: Color? = nil, _ width: CGFloat? = nil) -> some View {
        self.border(color ?? .orange, width: width ?? 2)
    }
}

#Preview { ContentView() }
