import SwiftUI

extension Habit.Dashboard.Sheet {

    var kindSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Habit")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            SegmentedControl(
                selection: $kind,
                options: [
                    (value: Habit.Kind.good, icon: "hand.thumbsup.fill", text: String(localized: "Good"), color: .green),
                    (value: Habit.Kind.bad, icon: "hand.raised.fill", text: String(localized: "Bad"), color: .red)
                ]
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
}
