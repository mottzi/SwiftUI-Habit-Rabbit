import SwiftUI

extension Habit.Dashboard.Sheet {
    
    var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Name")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            TextField("Stretching", text: $name)
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
