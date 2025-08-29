import SwiftUI

extension Habit.Dashboard.AddHabitSheet {
 
    enum FocusedField: CaseIterable {
        case habitName
        case habitUnit
        case target
        case icon
    }
    
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
    
    var keyboardToolbar: some View {
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
