import SwiftUI

extension Habit.Dashboard.EditHabitSheet {

    var kindSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Habit")
                .font(.headline)
                .fontWeight(.semibold)
            
            Picker("Habit Type", selection: $habitKind) {
                Text("Good").tag(Habit.Kind.good)
                Text("Bad").tag(Habit.Kind.bad)
            }
            .pickerStyle(.segmented)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
}