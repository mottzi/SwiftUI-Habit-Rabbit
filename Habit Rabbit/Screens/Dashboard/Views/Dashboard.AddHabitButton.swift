import SwiftUI

extension Habit.Dashboard {
    
    private var addHabitButton: some View {
        Button {
            presentAddSheet = true
        } label: {
            Image(systemName: "plus")
                .font(.title)
                .fontWeight(.medium)
                .foregroundStyle(colorScheme == .light ? .black : .white)
                .frame(width: 64, height: 64)
                .background { Habit.Card.Background(in: .circle, material: .ultraThinMaterial) }
                .padding()
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: presentAddSheet)
        .offset(x: 6, y: 0)
    }
    
    
}
