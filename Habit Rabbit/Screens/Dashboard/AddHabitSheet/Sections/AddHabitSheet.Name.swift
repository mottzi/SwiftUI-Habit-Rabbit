import SwiftUI

extension Habit.Dashboard.AddHabitSheet {
    
    var habitNameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Name")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .foregroundStyle(.secondary)
            
            TextField("Stretching", text: $habitName)
                .textFieldStyle(.plain)
                .font(.title)
                .fontWeight(.semibold)
                .focused($focusedField, equals: .habitName)
                .onSubmit {
                    Task {
                        try? await Task.sleep(for: .milliseconds(300))
                        advanceToNextField(from: .habitName)
                    }
                }
                .submitLabel(.next)
                .autocorrectionDisabled()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
}
