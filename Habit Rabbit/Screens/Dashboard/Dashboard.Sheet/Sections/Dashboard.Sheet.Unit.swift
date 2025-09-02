import SwiftUI

extension Habit.Dashboard.Sheet {

    var unitSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Unit")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            TextField("Sessions", text: $unit)
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
