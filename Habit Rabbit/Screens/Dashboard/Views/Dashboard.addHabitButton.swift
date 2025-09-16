import SwiftUI

extension Habit.Dashboard {
    
    @ViewBuilder
    var addHabitButton: some View {
        if #available(iOS 26, *) {
            Button {
                presentAddSheet = true
            } label: {
                Image(systemName: "plus")
                    .font(.title)
                    .fontWeight(.medium)
                    .padding()
                    .glassEffect()
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.selection, trigger: presentAddSheet)
            .offset(x: -12, y: 0)
        } else {
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
    
}
