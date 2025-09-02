import SwiftUI
import SwiftData

extension Habit.Dashboard {

    struct Sheet: View {

        struct InitialValues {

            var name: String
            var unit: String
            var icon: String
            var color: Color
            var target: Int?
            var kind: Habit.Kind

        }

        enum FocusedField: CaseIterable {
            case habitName
            case habitUnit
            case target
            case icon
        }

        @Environment(\.colorScheme) var colorScheme

        let initial: InitialValues
        let submitLabel: String
        let submitIcon: String
        let onSubmit: (_ name: String, _ unit: String,
                       _ icon: String,
                       _ color: Color,
                       _ target: Int,
                       _ kind: Habit.Kind) -> Void

        @FocusState var focusedField: FocusedField?

        @State var name: String
        @State var unit: String
        @State var icon: String
        @State var color: Color
        @State var showIconPicker = false
        @State var targetValue: Int?
        @State var kind: Habit.Kind

        let horizontalPadding: CGFloat = 16

        init(
            initial: InitialValues,
            submitLabel: String,
            submitIcon: String,
            onSubmit: @escaping (_ name: String, _ unit: String, _ icon: String, _ color: Color, _ target: Int, _ kind: Habit.Kind) -> Void
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

        private var isFormValid: Bool {
            !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !unit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            targetValue != nil && targetValue! > 0
        }

        private func handleSubmit() {
            guard isFormValid, let targetValue else { return }
            onSubmit(
                name.trimmingCharacters(in: .whitespacesAndNewlines),
                unit.trimmingCharacters(in: .whitespacesAndNewlines),
                icon,
                color,
                targetValue,
                kind
            )
        }

        // MARK: - Keyboard Navigation
        
        func advanceToNextField(from currentField: FocusedField? = nil) {
            let currentField = currentField ?? focusedField
            guard let currentField else { return }
            let nextField = currentField.next
            
            if nextField == .icon {
                focusedField = .icon
                showIconPicker = true
                focusedField = nil
            } else {
                focusedField = nextField
            }
        }
        
        func advanceToPreviousField() {
            guard let currentField = focusedField else { return }
            focusedField = currentField.previous
        }
        
        var keyboardToolbar: some ToolbarContent {
            ToolbarItem(placement: .keyboard){
                HStack {
                    Button("Previous") { advanceToPreviousField() }
                    .disabled(focusedField?.isFirst == true)
                    .fontWeight(.semibold)
                    
                    Button("Next") { advanceToNextField() }
                    .disabled(focusedField?.isLast == true)
                    .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button("Done") { focusedField = nil }
                    .fontWeight(.semibold)
                }
            }
        }

    }

}
