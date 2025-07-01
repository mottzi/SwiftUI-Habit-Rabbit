import SwiftUI
import AppComponents

struct ContentView: View {
    @State private var habitValues = Habit.examples.map { habit in
        Int.random(in: 0...habit.target * 2)
    }
    
    let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: gridColumns, spacing: 16) {
                    ForEach(Habit.examples.indices, id: \.self) { index in
                        HabitCard(
                            habit: Habit.examples[index],
                            habitCardType: .barChart,
                            currentValue: $habitValues[index]
                        )
                    }
                }
                .padding()
                .navigationTitle("Habit Rabbit")
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("", systemImage: "sparkles") {
                        habitValues = Habit.examples.map { habit in
                            Int.random(in: 0...habit.target * 2)
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("", systemImage: "trash") {
                        habitValues = Array(repeating: 0, count: habitValues.count)
                    }
                }
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
