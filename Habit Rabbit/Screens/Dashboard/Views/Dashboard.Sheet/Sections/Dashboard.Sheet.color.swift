import SwiftUI

extension Habit.Dashboard.Sheet {

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
                ForEach(Self.availableColors.enumerated, id: \.offset) { index, clr in
                    Button {
                        selectedColorIndex = index
                    } label: {
                        Circle()
                            .fill(clr.gradient)
                            .frame(width: 44, height: 44)
                            .overlay {
                                if selectedColorIndex == index {
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

}
