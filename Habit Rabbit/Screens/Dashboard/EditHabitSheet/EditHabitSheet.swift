import SwiftUI

extension Habit.Dashboard {

    struct EditHabitSheet: View {

        @Environment(\.colorScheme) var colorScheme
        @Environment(\.dismiss) private var dismiss
        @Environment(Habit.Dashboard.Manager.self) private var dashboardManager
        
        let habit: Habit
        
        @FocusState var focusedField: FocusedField?

        @State var habitName: String
        @State var habitUnit: String
        @State var selectedIcon: String
        @State var selectedColor: Color
        @State var showIconPicker = false
        @State var targetValue: Int?
        @State var habitKind: Habit.Kind
        
        let horizontalPadding: CGFloat = 16
        let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 6)

        init(habit: Habit) {
            self.habit = habit
            self._habitName = State(initialValue: habit.name)
            self._habitUnit = State(initialValue: habit.unit)
            self._selectedIcon = State(initialValue: habit.icon)
            self._selectedColor = State(initialValue: habit.color)
            self._targetValue = State(initialValue: habit.target)
            self._habitKind = State(initialValue: habit.kind)
        }

        var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 14) {
                        Text("Edit Habit: \(habit.name)")
                            .font(.title)
                            .foregroundColor(.primary)
                        kindSection
                        habitNameSection
                        Divider()
                        unitSection
                        Divider()
                        targetSection
                        Divider()
                        iconSection
                        Divider()
                        colorSection
                    }
                    .padding(.horizontal, horizontalPadding)
                }
                .background(Color(.systemBackground))
                .scrollBounceBehavior(.basedOnSize)
                .overlay(alignment: .bottom) {
                    updateButton
                        .padding(.vertical, 32)
                }
                .ignoresSafeArea(.keyboard)
                .toolbar {
                    keyboardToolbar
                    closeButtonToolbar
                }
                .presentationDetents([.large])
                .sheet(isPresented: $showIconPicker) { iconPickerSheet }
                .navigationTitle("Edit Habit")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        
    }
    
}

extension Habit.Dashboard.EditHabitSheet {

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

    private var updateButton: some View {
        Button(role: .none) {
            updateHabit()
        } label: {
            Label("Update Habit", systemImage: "checkmark")
                .fontWeight(.semibold)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .tint(.blue)
        .disabled(!isFormValid)
    }
    
    private func updateHabit() {
        guard isFormValid else { return }
        guard let targetValue else { return }
        
        dashboardManager.updateHabit(
            habit,
            name: habitName.trimmingCharacters(in: .whitespacesAndNewlines),
            unit: habitUnit.trimmingCharacters(in: .whitespacesAndNewlines),
            icon: selectedIcon,
            color: selectedColor,
            target: targetValue,
            kind: habitKind
        )
        dismiss()
    }

}