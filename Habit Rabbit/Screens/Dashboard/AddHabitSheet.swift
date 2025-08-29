import SwiftUI

extension Habit.Dashboard {

    struct AddHabitSheet: View {

        @Environment(\.colorScheme) private var colorScheme
        @Environment(\.dismiss) private var dismiss
        
        @FocusState private var focusedField: FocusedField?

        @State private var habitName = ""
        @State private var habitUnit = ""
        @State private var selectedIcon = "star.fill"
        @State private var selectedColor: Color = .blue
        @State private var showIconPicker = false
        @State private var targetValue: Int?
        
        private let horizontalPadding: CGFloat = 16
        
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
                    .padding(.top, 32)
                    .overlay(alignment: .topTrailing) {
                        closeButton
                            .padding(.trailing)
                            .padding(.top)
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
                .overlay(alignment: .bottom) {
                    addButton
                        .padding(.vertical, 32)
                        
                }
                .ignoresSafeArea(.keyboard)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        keyboardToolbar
                    }
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
 
    enum FocusedField: CaseIterable {
        case habitName
        case habitUnit
        case target
        case icon
    }
    
    private func advanceToNextField(from currentField: FocusedField? = nil) {
        let field = currentField ?? focusedField
        guard let field = field else { return }
        
        let nextField = field.next
        
        if nextField == .icon {
            // When advancing to icon field, open the icon picker
            focusedField = .icon
            showIconPicker = true
            focusedField = nil
        } else {
            focusedField = nextField
        }
    }
    
    private func advanceToPreviousField() {
        guard let currentField = focusedField else { return }
        focusedField = currentField.previous
    }
    
    @ViewBuilder
    private var keyboardToolbar: some View {
        if focusedField != nil {
            HStack {
                Button("Previous") {
                    advanceToPreviousField()
                }
                .disabled(focusedField?.isFirst == true)
                .fontWeight(.semibold)
                
                Button("Next") {
                    advanceToNextField()
                }
                .disabled(focusedField?.isLast == true)
                .fontWeight(.semibold)
                
                Spacer()
                
                Button("Done") {
                    focusedField = nil
                }
                .fontWeight(.semibold)
            }
        } else {
            EmptyView()
        }
    }
    
}

extension Habit.Dashboard.AddHabitSheet {

    private var closeButton: some View {
        Button(role: .cancel) {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(width: 32, height: 32)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.circle)
        .tint(.red)
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

extension Habit.Dashboard.AddHabitSheet {

    private var habitNameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Habit Name")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            TextField("Stretching", text: $habitName)
                .textFieldStyle(.plain)
                .font(.title)
                .fontWeight(.semibold)
                .focused($focusedField, equals: .habitName)
                .onSubmit {
                    Task {
                        try? await Task.sleep(for: .milliseconds(300))
                        advanceToNextField(from: .habitName)
                    }
                }
                .submitLabel(.next)
                .autocorrectionDisabled()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var unitSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Unit")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            TextField("Sessions", text: $habitUnit)
                .textFieldStyle(.plain)
                .font(.title)
                .fontWeight(.semibold)
                .focused($focusedField, equals: .habitUnit)
                .onSubmit {
                    Task {
                        try? await Task.sleep(for: .milliseconds(300))
                        advanceToNextField(from: .habitUnit)
                    }
                }
                .submitLabel(.next)
                .autocorrectionDisabled()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

}

extension Habit.Dashboard.AddHabitSheet {
    
    private var iconSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Icon")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            iconPickerButton
                .font(.title3)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var iconPickerButton: some View {
        Button {
            showIconPicker = true
        } label: {
            HStack(alignment: .lastTextBaseline) {
                Image(systemName: selectedIcon)
                    .font(.title2)
                    .foregroundStyle(colorScheme == .light ? .black : .white)
                    .padding(.leading, 1)
                
                Text("Change")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
        //            .offset(x: -4)
    }
    
    private var iconPickerSheet: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 6), spacing: 10) {
                    ForEach(Self.commonIcons, id: \.self) { icon in
                        Button {
                            Task {
                                selectedIcon = icon
                                try? await Task.sleep(for: .milliseconds(100))
                                showIconPicker = false
                                focusedField = nil
                            }
                        } label: {
                            Image(systemName: icon)
                                .font(.title3)
                                .foregroundStyle(selectedIcon == icon ? .white : (colorScheme == .light ? .black : .white))
                                .frame(width: 44, height: 44)
                                .padding(4)
                                .background {
                                    if selectedIcon == icon {
                                        Circle()
                                            .fill(.blue)
                                    } else {
                                        Habit.Card.Background(in: .circle)
                                    }
                                }
                            
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
                .safeAreaInset(edge: .top, alignment: .trailing) {
                    Button(role: .cancel) {
                        showIconPicker = false
                        focusedField = nil
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .frame(width: 36, height: 36)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.circle)
                    .tint(.red)
                    .padding(.vertical)
                    .padding(.trailing, 10)
                }
                
            }
        }
        .presentationDetents([.large])
        .presentationBackground {
            Rectangle()
                .fill(.thickMaterial)
                .padding(.bottom, -100)
        }
    }
    
}

extension Habit.Dashboard.AddHabitSheet {
    
    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Color")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            colorPicker
        }
    }
    
    private var colorPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Self.availableColors.enumerated, id: \.offset) { index, color in
                    Button {
                        selectedColor = color
                    } label: {
                        Circle()
                            .fill(color.gradient)
                            .frame(width: 44, height: 44)
                            .overlay {
                                if selectedColor == color {
                                    Circle()
                                        .strokeBorder(.primary, lineWidth: 3)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .contentMargins(.horizontal, horizontalPadding * 2)
        .padding(.horizontal, -horizontalPadding * 2)
    }
    
}

extension Habit.Dashboard.AddHabitSheet {

    private var targetSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Target")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            TextField("6", value: $targetValue, format: .number)
                .textFieldStyle(.plain)
                .font(.title)
                .fontWeight(.semibold)
                .keyboardType(.numberPad)
                .focused($focusedField, equals: .target)
                .onSubmit {
                    advanceToNextField()
                }

        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
}

extension Habit.Dashboard.AddHabitSheet {

    private static let availableColors: [Color] = [
        .blue,
        .orange,
        .green,
        .pink,
        .mint,
        .purple,
        .yellow,
        .red,
        .teal,
        .indigo,
        .brown,
        .gray,
        .cyan,
    ]

    private static let commonIcons: [String] = [
        "star.fill",
        "heart.fill",
        "flame.fill",
        "drop.fill",
        "leaf.fill",
        "moon.fill",
        "sun.max.fill",
        "cloud.rain.fill",
        "snowflake",
        "bolt.fill",
        "target",
        "book.fill",
        "pencil",
        "music.note",
        "camera.fill",
        "gamecontroller.fill",
        "figure.walk",
        "figure.run",
        "bicycle",
        "car.fill",
        "airplane",
        "house.fill",
        "building.2.fill",
        "cup.and.saucer.fill",
        "fork.knife",
        "pill.fill",
        "bed.double.fill",
        "laptopcomputer",
        "iphone",
        "headphones",
        "tv.fill",
        "film.fill",
        "gift.fill",
        "graduationcap.fill",
        "brain.head.profile",
        "dumbbell.fill",
        "lightbulb.fill",
        "paintbrush.fill",
        "wrench.fill",
        "briefcase.fill",
        "doc.text.fill",
        "calendar",
        "clock.fill",
        "alarm.fill",
        "bell.fill",
        "shield.fill",
        "lock.fill",
        "key.fill",
        "magnifyingglass",
        "plus.circle.fill",
        "checkmark.circle.fill",
        "xmark.circle.fill",
        "exclamationmark.triangle.fill",
        "info.circle.fill",
        "questionmark.circle.fill",
        "globe",
        "map.fill",
        "location.fill",
        "compass.drawing",
        "wallet.pass.fill",
        "creditcard.fill",
        "banknote.fill",
        "cart.fill",
        "bag.fill",
        "tshirt.fill",
        "shoe.fill",
        "eyeglasses",
        "ring.circle.fill",
        "speaker.wave.3.fill",
        "microphone.fill",
        "phone.fill",
        "message.fill",
        "envelope.fill",
        "paperplane.fill",
        "wifi",
        "antenna.radiowaves.left.and.right"
    ]
}
