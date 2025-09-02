import SwiftUI

extension Habit.Dashboard.Sheet {

    var targetSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Target")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            TextField("6", value: $targetValue, format: .number)
                .textFieldStyle(.plain)
                .font(.title)
                .fontWeight(.semibold)
                .keyboardType(.numberPad)
                .focused($focusedField, equals: .target)
                .onSubmit {
                    advanceToNextField()
                }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
}
