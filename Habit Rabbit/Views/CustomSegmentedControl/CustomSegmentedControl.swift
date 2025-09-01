import SwiftUI

struct CustomSegmentedControl<T: Hashable>: View {

    @Binding var selection: T
    let options: [(value: T, icon: String, text: String, color: Color)]
    
    @State private var selectedIndex: Int = 0
    
    private var selectedOptionColor: Color {
        guard let index = options.firstIndex(where: { $0.value == selection }) else { return .blue }
        return options[index].color
    }
    
    var body: some View {
        GeometryReader { geometry in
            let segmentWidth = geometry.size.width / CGFloat(options.count)
            
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 10)
                    .fill(.quaternary)
                
                // Moving selected background
                RoundedRectangle(cornerRadius: 10)
                    .fill(selectedOptionColor)
                    .frame(width: segmentWidth - 4, height: geometry.size.height - 4)
                    .offset(x: CGFloat(selectedIndex) * segmentWidth - geometry.size.width / 2 + segmentWidth / 2)
                
                // Segment buttons
                HStack(spacing: 0) {
                    ForEach(options.enumerated, id: \.offset) { index, option in
                        Button {
                            withAnimation {
                                selection = option.value
                                selectedIndex = index
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: option.icon)
                                    .font(.system(size: 16, weight: .semibold))
                                Text(option.text)
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(selection == option.value ? .white : .secondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .contentShape(.rect)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .frame(height: 44)
        .padding(2)
        .onAppear {
            if let index = options.firstIndex(where: { $0.value == selection }) {
                selectedIndex = index
            }
        }
        .onChange(of: selection) { _, newValue in
            if let index = options.firstIndex(where: { $0.value == newValue }) {
                selectedIndex = index
            }
        }
    }
    
}
