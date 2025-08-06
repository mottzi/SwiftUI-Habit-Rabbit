
import SwiftUI

struct HabitDetailView: View {
    
    @Environment(Habit.Card.Manager.self) var cardManager
    
    var body: some View {
        Text(cardManager.name)
    }
    
}
