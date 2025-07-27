import SwiftUI

extension Habit.Dashboard {
    struct ModePicker: View {
        var width: CGFloat
        @Binding var mode: Habit.Card.Mode
        
        typealias Mode = Habit.Card.Mode
        
        var body: some View {
            HStack(spacing: 0) {
                ForEach(Habit.Card.Mode.allCases, id: \.self) { item in
                    Button {
                        mode = mode == item ? mode.next : item
                    } label: {
                        Text(item.rawValue)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(mode == item ? .primary : .secondary)
                            .fontWeight(mode == item ? .bold : .medium)
                    }
                    .buttonStyle(.plain)
                    .contentShape(.rect)
                    .frame(width: width / 3)
                    .padding(.vertical, 6)
                }
            }
            .background {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .frame(width: width / 3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .offset(x: CGFloat(Mode.allCases.firstIndex(of: mode) ?? 0) * (width / 3), y: 0)
                    .animation(.spring(duration: 0.62), value: mode)
            }
            .frame(width: width)
        }
    }
}
