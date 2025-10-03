import SwiftUI

extension Habit.Dashboard {
    
    @ToolbarContentBuilder
    var addHabitToolbarButton: some ToolbarContent {
        if #available(iOS 26, *) {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                }
            }
        }
    }
    
}

extension Habit.Dashboard {
    
    @ViewBuilder
    var addHabitButton: some View {
        if #unavailable(iOS 26) {
            Button {
                showAddSheet = true
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
            .sensoryFeedback(.selection, trigger: showAddSheet)
        }
        
    }
    
}
