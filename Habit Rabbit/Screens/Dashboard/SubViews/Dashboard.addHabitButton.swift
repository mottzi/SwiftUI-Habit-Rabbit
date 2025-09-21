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
                    .frame(width: 70, height: 70)
                    .glassEffect(.regular.interactive())
                    .offset(x: 6, y: 0)
                    .padding(.top, 40)
                    .frame(width: 100, height: 170, alignment: .top)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.selection, trigger: presentAddSheet)
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
                    .offset(x: 6, y: 0)
                    .padding(.top, 40)
                    .frame(width: 100, height: 170, alignment: .top)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.selection, trigger: presentAddSheet)
        }
        
    }
    
}
