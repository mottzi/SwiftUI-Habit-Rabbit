import SwiftUI

extension Habit.Dashboard {
    
    @ViewBuilder
    var emptyView: some View {
        if cardManagers.isEmpty {
            VStack {
                VStack {
                    Image(systemName: "rectangle.portrait.slash.fill")
                        .font(.system(size: 46))
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 6)
                    Text("No Habits")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Create your first habit to get started!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 50)
            }
            .padding(.top, 100)
        }
    }
    
}
