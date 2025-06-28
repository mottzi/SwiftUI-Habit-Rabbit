import SwiftUI
import AppComponents

struct ContentView: View {
    @State private var value1 = 0
    @State private var value2 = 0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                HStack(spacing: 16) {
                    HabitCard(
                        habit: .examples[0],
                        habitCardType: .barChart,
                        currentValue: $value1
                    )
                    HabitCard(
                        habit: .examples[1],
                        habitCardType: .barChart,
                        currentValue: $value2
                    )
                }
                .padding()
                .navigationTitle("Habit Rabbit")
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("", systemImage: "trash") {
                        value1 = 0
                        value2 = 0
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
