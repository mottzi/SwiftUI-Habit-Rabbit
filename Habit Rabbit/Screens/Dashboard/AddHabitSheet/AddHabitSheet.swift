import SwiftUI

extension Habit.Dashboard {

    struct AddHabitSheet: View {

        @Environment(\.colorScheme) var colorScheme
        @Environment(\.dismiss) private var dismiss
        
        @FocusState var focusedField: FocusedField?

        @State var habitName = ""
        @State var habitUnit = ""
        @State var selectedIcon = "star.fill"
        @State var selectedColor: Color = .blue
        @State var showIconPicker = false
        @State var targetValue: Int?
        
        let horizontalPadding: CGFloat = 16
        let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 6)

        var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 14) {
                        habitNameSection
                        Divider()
                        unitSection
                        Divider()
                        targetSection
                        Divider()
                        iconSection
                        Divider()
                        colorSection
                        Divider()
                    }
                    .padding(horizontalPadding)
                    .padding(.horizontal, horizontalPadding)
                }
                .scrollBounceBehavior(.basedOnSize)
                .overlay(alignment: .bottom) {
                    addButton
                        .padding(.vertical, 32)
                }
                .ignoresSafeArea(.keyboard)
                .toolbar {
                    keyboardToolbar
                    closeButtonToolbar
                }
                .presentationBackground {
                    Rectangle()
                        .fill(.thickMaterial)
                        .padding(.bottom, -100)
                }
                .presentationDetents([.large])
                .interactiveDismissDisabled()
                .sheet(isPresented: $showIconPicker) { iconPickerSheet }
            }
        }
        
    }
    
}

extension Habit.Dashboard.AddHabitSheet {

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
            dismiss()
        } label: {
            Label("Add Habit", systemImage: "plus")
                .fontWeight(.semibold)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .tint(.blue)
    }

}
