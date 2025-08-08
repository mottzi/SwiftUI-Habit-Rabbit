import SwiftUI

extension Habit {

    struct AverageView: View {

        @Environment(Habit.Card.Manager.self) var cardManager
        @Environment(\.colorScheme) var colorScheme

        var body: some View {
            HStack(spacing: 16) {
                AverageColumn(
                    title: "Today",
                    currentValue: cardManager.currentValue(for: .daily),
                    target: cardManager.currentTarget(for: .daily),
                    unit: cardManager.unit,
                    color: cardManager.color,
                    kind: cardManager.kind,
                    mode: .daily
                )
                AverageColumn(
                    title: "Week",
                    currentValue: cardManager.currentValue(for: .weekly),
                    target: cardManager.currentTarget(for: .weekly),
                    unit: cardManager.unit,
                    color: cardManager.color,
                    kind: cardManager.kind,
                    mode: .weekly
                )
                AverageColumn(
                    title: "Month",
                    currentValue: cardManager.currentValue(for: .monthly),
                    target: cardManager.currentTarget(for: .monthly),
                    unit: cardManager.unit,
                    color: cardManager.color,
                    kind: cardManager.kind,
                    mode: .monthly
                )
            }
            .frame(maxWidth: .infinity)
            .frame(height: 232)
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .background { Habit.CardSurface() }
        }

    }

}
