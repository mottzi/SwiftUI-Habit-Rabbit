import SwiftUI

extension Habit.Dashboard {

    struct AddHabitSheet: View {

        @Environment(\.colorScheme) private var colorScheme
        @Environment(\.dismiss) private var dismiss
        
        @State private var habitName = ""
        @State private var habitUnit = ""

        var body: some View {
            NavigationStack {
                VStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Habit Name")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        TextField("Stretching", text: $habitName)
                            .textFieldStyle(.plain)
                            .font(.title)
                            .fontWeight(.semibold)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Unit")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        TextField("Sessions", text: $habitUnit)
                            .textFieldStyle(.plain)
                            .font(.title)
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                }
                .padding()
                .padding(.horizontal)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) { closeButton }
                    ToolbarItem(placement: .topBarTrailing) { addButton }
                }
            }
            .presentationBackground {
                Rectangle()
                    .fill(.thickMaterial)
                    .padding(.bottom, -100)
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }

        private var closeButton: some View {
            Button(role: .cancel) {
                dismiss()
            } label: {
                Text("Cancel")
                    .fontWeight(.semibold)
            }
            .tint(.red)
        }

        private var addButton: some View {
            Button(role: .none) {
                dismiss()
            } label: {
                Text("Add Habit")
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .tint(.blue)
        }

    }
    
}
