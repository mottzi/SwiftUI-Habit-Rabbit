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
                        habit: .example,
                        habitCardType: .barChart,
                        currentValue: $value1
                    )
                    HabitCard(
                        habit: .example,
                        habitCardType: .barChart,
                        currentValue: $value2
                    )
                }
                .padding()
                .navigationTitle("Habit Rabbit")
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
