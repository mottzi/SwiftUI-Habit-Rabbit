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
        //            .offset(x: -4)
    }
    
    var iconPickerSheet: some View {
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
