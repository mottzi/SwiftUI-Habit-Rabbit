
import SwiftUI

struct HabitDetailView: View {
    
    var cardManager: Habit.Card.Manager
    
    var body: some View {
        Text(cardManager.habit.name)
    }
    
}
