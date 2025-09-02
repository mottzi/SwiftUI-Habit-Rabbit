import SwiftUI

extension Habit.Dashboard.AddHabitSheet {

    var iconSection: some View {
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
    }
        
    var iconPickerSheet: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
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
                                    switch selectedIcon == icon {
                                        case true:  Circle().fill(.blue)
                                        case false: Habit.Card.Background(in: .circle)
                                    }
                                }
                            
                        }
                        .buttonStyle(.plain)
                    }
                }
//                .padding(.horizontal, 16)
                .padding(.vertical, 32)
                
            }
            .toolbar { closeButton }
        }
        .presentationDetents([.large])
        .presentationBackground {
            Rectangle()
                .fill(.thickMaterial)
                .padding(.bottom, -100)
        }
    }
    
    private var closeButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(role: .cancel) {
                showIconPicker = false
                focusedField = nil
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
