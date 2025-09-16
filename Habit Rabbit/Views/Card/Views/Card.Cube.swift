import SwiftUI

extension Habit.Card {

    struct Cube: View {

        @Environment(\.colorScheme) var colorScheme

        let value: Habit.Value?
        let habit: Habit
        let cardColor: Color

        var body: some View {
            RoundedRectangle(cornerRadius: 4)
                .fill(Habit.Card.cubeColor(for: value, habit: habit, cardColor: cardColor))
                .strokeBorder(.tertiary, lineWidth: Habit.Card.cubeStrokeWidth(for: value, habit: habit, colorScheme: colorScheme))
                .brightness(Habit.Card.cubeBrightness(for: value, habit: habit, colorScheme: colorScheme))
                .frame(width: 16, height: 16)
        }

    }
    
}
