import SwiftUI

extension Habit.Card.DetailView {

    @ViewBuilder
    var valuesList: some View {
        List(values) { value in
            valueRow(for: value)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    swipeButtons(for: value)
                }
                .contextMenu {
                    swipeButtons(for: value)
                }
        }
        .safeAreaInset(edge: .top) { emptyView }
    }
    
    func valueRow(for value: Habit.Value) -> some View {
        HStack {
            Habit.Card.Cube(
                value: value,
                habit: cardManager.habit
            )
            Text(verbatim: "\(value.date.formatted(.date))")
            Spacer()
            Text(verbatim: "\(value.currentValue)")
        }
    }

}

extension Habit.Card.DetailView {
    
    @ViewBuilder
    func swipeButtons(for value: Habit.Value) -> some View {
        Button("Edit", systemImage: "pencil") {
            editingValue = value
            editValueText = "\(value.currentValue)"
        }
        .tint(.blue)
        .labelStyle(.iconOnly)
        
        Button("Reset", systemImage: "trash") {
            detailManager?.resetValue(value)
        }
        .tint(.red)
        .labelStyle(.iconOnly)
    }
    
    @ViewBuilder
    var editValueMessage: some View {
        if let value = editingValue {
            Text("Enter new value for \(value.date.formatted(.date))")
        }
    }
    
    @ViewBuilder
    var editValueAlert: some View {
        TextField("Value", text: $editValueText)
            .keyboardType(.numberPad)
        Button("Cancel", action: cancelEdit)
        Button("Save", action: saveEdit)
    }
    
    private func cancelEdit() {
        editingValue = nil
        editValueText = ""
    }
    
    private func saveEdit() {
        if let value = editingValue,
           let newValue = Int(editValueText) {
            detailManager?.updateValue(value, to: newValue)
        }
        editingValue = nil
        editValueText = ""
    }
    
}
