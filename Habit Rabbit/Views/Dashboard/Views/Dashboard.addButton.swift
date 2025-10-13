import SwiftUI

extension Habit.Dashboard {
    
    var addButton: some View {
        Button {
            showAddSheet = true
        } label: {
            Image(systemName: "plus")
                .font(.title)
                .fontWeight(.medium)
                .padding(14)
        }
        .buttonStyle(.glass)
        .clipShape(.circle)
        .buttonBorderShape(.circle)
        .sensoryFeedback(.selection, trigger: showAddSheet)
        .padding(.trailing, 10)
    }
    
}
