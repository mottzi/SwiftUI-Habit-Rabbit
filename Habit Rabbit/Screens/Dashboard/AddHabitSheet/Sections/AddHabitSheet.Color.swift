import SwiftUI

extension Habit.Dashboard.AddHabitSheet {

    var colorSection: some View {
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
