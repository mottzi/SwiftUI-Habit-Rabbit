import SwiftUI

extension Habit.Dashboard.Sheet {

    struct Add: View {

        @Environment(\.colorScheme) var colorScheme
        @Environment(\.dismiss) private var dismiss
        @Environment(Habit.Dashboard.Manager.self) private var dashboardManager
        
        @FocusState var focusedField: Habit.Dashboard.Sheet.FocusedField?

        @State var habitName = ""
        @State var habitUnit = ""
        @State var selectedIcon = "star.fill"
        @State var selectedColor: Color = .blue
        @State var showIconPicker = false
        @State var targetValue: Int?
        @State var habitKind: Habit.Kind = .good
        
        let horizontalPadding: CGFloat = 16
        let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 6)

        var body: some View {
            NavigationStack {
                Habit.Dashboard.Sheet(
                    initial: .init(
                        name: "",
                        unit: "",
                        icon: "star.fill",
                        color: .blue,
                        target: nil,
                        kind: .good
                    ),
                    submitLabel: String(localized: "Add Habit"),
                    submitIcon: "plus",
                    onSubmit: { newHabit in
                        dashboardManager.addHabit(newHabit)
                        dismiss()
                    }
                )
                .toolbar { closeButtonToolbar }
                .presentationBackground {
                    Rectangle()
                        .fill(.thickMaterial)
                        .padding(.bottom, -100)
                }
                .presentationDetents([.large])
                .interactiveDismissDisabled()
                .navigationTitle("Add Habit")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        
    }
    
}

extension Habit.Dashboard.Sheet.Add {

    private var isFormValid: Bool {
        !habitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !habitUnit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        targetValue != nil && targetValue! > 0
    }

    private var closeButtonToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(role: .cancel) {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.circle)
            .tint(.red)
            .padding(.trailing, -8)
        }
    }

    private var addButton: some View {
        Button(role: .none) {
            addHabit()
        } label: {
            Label("Add Habit", systemImage: "plus")
                .fontWeight(.semibold)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .tint(.blue)
        .disabled(!isFormValid)
    }
    
    private func addHabit() {
        guard isFormValid else { return }
        guard let targetValue else { return }
        
        let habit = Habit(
            name: habitName.trimmingCharacters(in: .whitespacesAndNewlines),
            unit: habitUnit.trimmingCharacters(in: .whitespacesAndNewlines),
            icon: selectedIcon,
            color: selectedColor,
            target: targetValue,
            kind: habitKind
        )
        
        dashboardManager.addHabit(habit)
        dismiss()
    }

}
