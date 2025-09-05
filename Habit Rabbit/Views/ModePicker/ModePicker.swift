import SwiftUI

extension Habit.Dashboard {
    
    struct ModePicker: View {
        
        let width: CGFloat
        let mode: Habit.Card.Mode
        let onSelection: (Habit.Card.Mode) -> Void
        
        var body: some View {
            HStack(spacing: 0) {
                ForEach(Habit.Card.Mode.allCases, id: \.self) { item in
                    Button {
                        let newMode = mode == item ? mode.next : item
                        onSelection(newMode)
                    } label: {
                        Text(item.localizedTitle)
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
            .frame(width: width)
            .background {
                selectedIndicator
            }
        }
        
        private var selectedIndicator: some View {
            Habit.Card.Background(in: .capsule)
                .showShadows(false)
                .frame(width: width / 3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .offset(
                    x: CGFloat(Habit.Card.Mode.allCases.firstIndex(of: mode) ?? 0) * (width / 3),
                    y: 0
                )
                .animation(.spring(duration: 0.62), value: mode)
        }
    }
    
}
