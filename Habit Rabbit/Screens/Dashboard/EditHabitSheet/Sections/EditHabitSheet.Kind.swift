import SwiftUI

extension Habit.Dashboard.EditHabitSheet {

    var kindSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Habit")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            CustomSegmentedControl(
                selection: $habitKind,
                options: [
                    (value: Habit.Kind.good, icon: "hand.thumbsup.fill", text: "Good", color: .green),
                    (value: Habit.Kind.bad, icon: "hand.raised.fill", text: "Bad", color: .red)
                ]
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
}
