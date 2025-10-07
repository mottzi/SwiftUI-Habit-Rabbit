import SwiftUI
import SwiftData

extension Habit.Dashboard {
    
    struct Sheet: View {
        
        @Environment(\.colorScheme) var colorScheme
        
        let initial: InitialValues
        let submitLabel: String
        let submitIcon: String
        let onSubmit: (Habit) -> ()
        
        @FocusState var focusedField: FocusedField?
        
        @State var name: String
        @State var unit: String
        @State var icon: String
        @State var selectedColorIndex: Int
        @State var showIconPicker = false
        @State var targetValue: Int?
        @State var kind: Habit.Kind
        
        let horizontalPadding: CGFloat = 16
        
        struct InitialValues {
            
            var name: String
            var unit: String
            var icon: String
            var color: Color
            var target: Int?
            var kind: Habit.Kind
            
        }
        
        init(
            initial: InitialValues,
            submitLabel: String,
            submitIcon: String,
            onSubmit: @escaping (Habit) -> ()
        ) {
            self.initial = initial
            self.submitLabel = submitLabel
            self.submitIcon = submitIcon
            self.onSubmit = onSubmit
            self._name = State(initialValue: initial.name)
            self._unit = State(initialValue: initial.unit)
            self._icon = State(initialValue: initial.icon)
            let colorIndex = Edit.colorIndex(for: initial.color)
            self._selectedColorIndex = State(initialValue: colorIndex)
            self._targetValue = State(initialValue: initial.target)
            self._kind = State(initialValue: initial.kind)
        }
    }
}

extension Habit.Dashboard.Sheet {

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                kindSection
                nameSection
                Divider()
                unitSection
                Divider()
                targetSection
                Divider()
                iconSection
                Divider()
                colorSection
            }
            .padding(horizontalPadding)
            .padding(.horizontal, horizontalPadding)
        }
        .scrollBounceBehavior(.basedOnSize)
        .overlay(alignment: .bottom) {
            Button(role: .none) {
                handleSubmit()
            } label: {
                Label(submitLabel, systemImage: submitIcon)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .tint(.blue)
            .disabled(!isFormValid)
            .padding(.vertical, 32)
        }
        .ignoresSafeArea(.keyboard)
        .toolbar { keyboardButtons }
        .sheet(isPresented: $showIconPicker) { iconPickerSheet }
    }

}


extension Habit.Dashboard.Sheet {

    private var isFormValid: Bool {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        guard !unit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        guard let targetValue, targetValue > 0 else { return false }
        return true
    }
    
    private func handleSubmit() {
        guard isFormValid, let targetValue else { return }
        let habit = Habit(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            unit: unit.trimmingCharacters(in: .whitespacesAndNewlines),
            icon: icon,
            color: Self.availableColors[selectedColorIndex],
            target: targetValue,
            kind: kind
        )
        onSubmit(habit)
    }
    
}
