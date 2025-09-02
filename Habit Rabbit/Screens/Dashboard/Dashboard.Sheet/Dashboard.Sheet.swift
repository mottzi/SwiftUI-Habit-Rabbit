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
        @State var color: Color
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
            self._color = State(initialValue: initial.color)
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
        .toolbar { keyboardToolbar }
        .sheet(isPresented: $showIconPicker) { iconPickerSheet }
    }

}


extension Habit.Dashboard.Sheet {

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !unit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        targetValue != nil && targetValue! > 0
    }
    
    private func handleSubmit() {
        guard isFormValid, let targetValue else { return }
        let habit = Habit(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            unit: unit.trimmingCharacters(in: .whitespacesAndNewlines),
            icon: icon,
            color: color,
            target: targetValue,
            kind: kind
        )
        onSubmit(habit)
    }
    
}
