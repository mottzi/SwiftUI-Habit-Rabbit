import SwiftUI

extension Habit.Dashboard.EditHabitSheet {

    var unitSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Unit")
                .font(.headline)
                .fontWeight(.semibold)
            TextField("Sessions", text: $habitUnit)
                .textFieldStyle(.plain)
                .font(.title)
                .fontWeight(.semibold)
                .focused($focusedField, equals: .habitUnit)
                .onSubmit {
                    Task {
                        try? await Task.sleep(for: .milliseconds(300))
                        advanceToNextField(from: .habitUnit)
                    }
                }
                .submitLabel(.next)
                .autocorrectionDisabled()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

}