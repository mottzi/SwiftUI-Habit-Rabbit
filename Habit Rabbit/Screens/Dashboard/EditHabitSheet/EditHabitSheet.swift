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
        @State var selectedColorIndex: Int
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
            // Find the closest matching color index
            let colorIndex = Self.findClosestColorIndex(for: habit.color)
            self._selectedColorIndex = State(initialValue: colorIndex)
            self._targetValue = State(initialValue: habit.target)
            self._habitKind = State(initialValue: habit.kind)
        }

        var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 14) {
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
                    .padding(horizontalPadding)
                    .padding(.horizontal, horizontalPadding)
                }
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
                .presentationBackground {
                    Rectangle()
                        .fill(.thickMaterial)
                        .padding(.bottom, -100)
                }
                .presentationDetents([.large])
                .interactiveDismissDisabled()
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
            color: Self.availableColors[selectedColorIndex],
            target: targetValue,
            kind: habitKind
        )
        dismiss()
    }
    
    static func findClosestColorIndex(for color: Color) -> Int {
        // Convert the color to a comparable format and find the best match
        // For now, we'll use a simple approach by comparing against known colors
        let availableColors = Self.availableColors
        
        // Try to match by creating UIColors and comparing their components
        let targetUIColor = UIColor(color)
        var targetRed: CGFloat = 0, targetGreen: CGFloat = 0, targetBlue: CGFloat = 0, targetAlpha: CGFloat = 0
        targetUIColor.getRed(&targetRed, green: &targetGreen, blue: &targetBlue, alpha: &targetAlpha)
        
        var bestMatchIndex = 0
        var bestDistance = CGFloat.greatestFiniteMagnitude
        
        for (index, availableColor) in availableColors.enumerated() {
            let availableUIColor = UIColor(availableColor)
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            availableUIColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            // Calculate Euclidean distance in RGB space
            let distance = sqrt(
                pow(targetRed - red, 2) +
                pow(targetGreen - green, 2) +
                pow(targetBlue - blue, 2)
            )
            
            if distance < bestDistance {
                bestDistance = distance
                bestMatchIndex = index
            }
        }
        
        return bestMatchIndex
    }

}
