import SwiftUI

extension Habit.Dashboard {
    
    var title: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            VStack(alignment: .leading, spacing: 0) {
                Text(verbatim: "Habit Rabbit")
                    .font(.largeTitle)
                Text(verbatim: dashboardManager.lastDay.formatted(.weekdayDate))
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fontDesign(.monospaced)
            }
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 12)
            .padding(.leading, 4)
        }
    }
    
}