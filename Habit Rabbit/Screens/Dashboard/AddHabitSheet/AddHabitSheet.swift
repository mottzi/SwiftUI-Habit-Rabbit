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

    static let availableColors: [Color] = [
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

    static let commonIcons: [String] = [
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
