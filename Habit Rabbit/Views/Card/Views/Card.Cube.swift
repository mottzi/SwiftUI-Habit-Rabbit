import SwiftUI

extension Habit.Card {

    struct Cube: View {

        @Environment(\.colorScheme) var colorScheme

        let value: Habit.Value?
        let habit: Habit

        var body: some View {
            RoundedRectangle(cornerRadius: 4)
                .fill(cubeStyle)
                .strokeBorder(.tertiary, lineWidth: cubeBorderWidth)
                .brightness(cubeBrightness)
                .frame(width: 16, height: 16)
        }

    }
    
}

extension Habit.Card.Cube {
    
    var cubeStyle: AnyShapeStyle {
        guard let value else {
            return switch habit.kind {
                case .good: AnyShapeStyle(.quaternary)
                case .bad: AnyShapeStyle(habit.color)
            }
        }
        
        let meetsTarget = switch habit.kind {
            case .good: value.currentValue >= habit.target
            case .bad: value.currentValue < habit.target
        }
        
        return switch meetsTarget {
            case true: AnyShapeStyle(habit.color)
            case false: AnyShapeStyle(.quaternary)
        }
    }
    
    var cubeBrightness: Double {
        guard let value else { return 0 }
        let isDark = colorScheme == .dark
        let exceedsTarget = value.currentValue > habit.target
        let meetsTarget = value.currentValue == habit.target
        
        return switch (habit.kind, isDark, exceedsTarget, meetsTarget) {
            case (.good, true, true, _)   :  0.1   // exceeding good habit in dark mode: brighter
            case (.good, true, false, _)  : -0.1   // not exceeding good habit in dark mode: darker
            case (.good, false, true, _)  : -0.1   // exceeding good habit in light mode: darker
            case (.good, false, false, _) :  0.1   // not exceeding good habit target in light mode: brighter
            case (.bad, _, false, false)  :  0     // below bad habit: no adjustment
            case (.bad, _, false, true)   :  0.2   // meeting bad habit: brighter
            case (.bad, true, true, _)    : -0.6   // exceeding bad habit in dark mode: much darker
            case (.bad, false, true, _)   : -0.8   // exceeding bad habit in light mode: darker
        }
    }
    
    var cubeBorderWidth: Double {
        guard let value else { return 0 }
        let isDark = colorScheme == .dark
        let exceedsTarget = value.currentValue > habit.target
        
        return switch (habit.kind, isDark, exceedsTarget) {
            case (.bad, true, true) : 0.75  // exceeding bad habit in dark mode: medium stroke
            default                 : 0     // no stroke
        }
    }
    
}
