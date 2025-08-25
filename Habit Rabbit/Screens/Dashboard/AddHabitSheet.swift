import SwiftUI

extension Habit.Dashboard {

    struct AddHabitSheet: View {

        @Environment(\.colorScheme) private var colorScheme
        @Environment(\.dismiss) private var dismiss
        
        @State private var habitName = ""
        @State private var habitUnit = ""
        @State private var selectedIcon = "star.fill"
        @State private var showIconPicker = false

        var body: some View {
            NavigationStack {
                VStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Habit Name")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        TextField("Stretching", text: $habitName)
                            .textFieldStyle(.plain)
                            .font(.title)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Unit")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        TextField("Sessions", text: $habitUnit)
                            .textFieldStyle(.plain)
                            .font(.title)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Divider()

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
                    
                    Divider()

                    Spacer()
                }
                .padding()
                .padding(.horizontal)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) { closeButton }
                    ToolbarItem(placement: .topBarTrailing) { addButton }
                }
            }
            .presentationBackground {
                Rectangle()
                    .fill(.thickMaterial)
                    .padding(.bottom, -100)
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            .interactiveDismissDisabled()
            .sheet(isPresented: $showIconPicker) { iconPickerSheet }
        }

        private var closeButton: some View {
            Button(role: .cancel) {
                dismiss()
            } label: {
                Text("Cancel")
                    .fontWeight(.semibold)
            }
            .tint(.red)
        }

        private var addButton: some View {
            Button(role: .none) {
                dismiss()
            } label: {
                Text("Add Habit")
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .tint(.blue)
        }

        private var iconPickerButton: some View {
            Button {
                showIconPicker = true
            } label: {
                HStack {
                    Image(systemName: selectedIcon)
                        .foregroundStyle(colorScheme == .light ? .black : .white)
                        .frame(width: 44, height: 44)
                        .padding(6)
                        .background { Habit.Card.Background(in: .circle) }
                    
//                    Text("Change")
//                        .font(.subheadline)
//                        .fontWeight(.semibold)
//                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
            .offset(x: -4)
        }

        private var iconPickerSheet: some View {
            NavigationStack {
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 6), spacing: 10) {
                        ForEach(commonIcons, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
//                                showIconPicker = false
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
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Close") {
                            showIconPicker = false
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationBackground {
                Rectangle()
                    .fill(.thickMaterial)
                    .padding(.bottom, -100)
            }
            .interactiveDismissDisabled()
        }

        private var commonIcons: [String] {
            [
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

    }
    
}
