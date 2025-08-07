
import SwiftUI

struct HabitDetailView: View {
    
    @Environment(Habit.Card.Manager.self) var cardManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Habit.Card()
                    .cardMode(.daily)
                    .containerRelativeFrame(.horizontal, count: 2, spacing: 16)
                Habit.Card()
                    .cardMode(.weekly)
                    .containerRelativeFrame(.horizontal, count: 2, spacing: 16)
                Habit.Card()
                    .cardMode(.monthly)
                    .containerRelativeFrame(.horizontal, count: 2, spacing: 16)
            }
            .environment(cardManager)
            .frame(maxWidth: .infinity)
            .padding(16)
            .padding(.top, 16)
        }
    }
    
}
